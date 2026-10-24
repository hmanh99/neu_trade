-- Migration: admin_feature
-- Administrative tools: Post approval, report handling, and restricted circulation statistics.

begin;

-- ─── 1. Admin Column & Helper on sinh_vien ──────────────────────────────────
alter table public.sinh_vien
  add column if not exists is_admin boolean not null default false;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select is_admin from public.sinh_vien where sinhvien_id = auth.uid()),
    false
  );
$$;

revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

-- Protect is_admin from client updates
create or replace function public.protect_sinh_vien_is_admin()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin')
     or (current_setting('request.jwt.claim.role', true) = 'service_role') then
    return new;
  end if;

  if tg_op = 'INSERT' then
    new.is_admin := false;
  elsif tg_op = 'UPDATE' then
    new.is_admin := old.is_admin;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_protect_sinh_vien_is_admin on public.sinh_vien;
create trigger trg_protect_sinh_vien_is_admin
before insert or update on public.sinh_vien
for each row execute function public.protect_sinh_vien_is_admin();

-- ─── 2. Post Creation Default Status (DaAn) ─────────────────────────────────
alter table public.tin_dang
  alter column trang_thai_tin set default 'DaAn';

create or replace function public.create_post(
  p_request_id uuid,
  p_document jsonb,
  p_post jsonb,
  p_images jsonb default '[]'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_student public.sinh_vien%rowtype;
  v_document public.tai_lieu%rowtype;
  v_post public.tin_dang%rowtype;
  v_payload jsonb;
  v_existing public.post_requests%rowtype;
  v_image_urls text[];
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if p_request_id is null then raise exception 'Missing request ID'; end if;
  if p_images is null
      or jsonb_typeof(p_images) <> 'array'
      or jsonb_array_length(p_images) not between 1 and 10 then
    raise exception 'Between one and ten images are required';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text || p_request_id::text, 0)
  );
  v_payload := pg_catalog.jsonb_build_object(
    'document', p_document,
    'post', p_post,
    'images', p_images
  );

  select * into v_existing
  from public.post_requests
  where sinhvien_id = v_user and request_id = p_request_id;

  if found then
    if v_existing.payload <> v_payload then
      raise exception 'Request payload changed';
    end if;
    return public.get_post_result(p_request_id);
  end if;

  select * into v_student
  from public.sinh_vien
  where sinhvien_id = v_user;

  if not found
      or nullif(pg_catalog.btrim(v_student.msv), '') is null
      or nullif(pg_catalog.btrim(v_student.ho_ten), '') is null then
    raise exception 'Complete student profile first';
  end if;
  if v_student.msv !~ '^[A-Za-z0-9]+$' then
    raise exception 'Invalid student code';
  end if;
  if coalesce(pg_catalog.char_length(pg_catalog.btrim(p_post ->> 'tieu_de')), 0)
      not between 1 and 255 then
    raise exception 'Invalid title';
  end if;
  if coalesce(pg_catalog.char_length(pg_catalog.btrim(p_post ->> 'dia_chi')), 0) > 50 then
    raise exception 'Invalid address';
  end if;
  if coalesce(pg_catalog.char_length(pg_catalog.btrim(p_document ->> 'ten_sach')), 0) = 0 then
    raise exception 'Missing document name';
  end if;
  if (p_document ->> 'gia_ban') is null
      or (p_document ->> 'gia_ban')::numeric < 0 then
    raise exception 'Invalid price';
  end if;
  if (p_document ->> 'nam_xuat_ban') is not null
      and ((p_document ->> 'nam_xuat_ban')::integer < 1
        or (p_document ->> 'nam_xuat_ban')::integer
          > pg_catalog.date_part('year', current_date)::integer) then
    raise exception 'Invalid publication year';
  end if;

  if exists (
    select 1
    from pg_catalog.jsonb_array_elements(p_images) image
    where image ->> 'path' is null
      or image ->> 'url' is null
      or image ->> 'path' !~ (
        '^' || v_student.msv || '/' || p_request_id::text
        || '/[0-9][.](jpg|png|webp|heic|heif)$'
      )
      or image ->> 'url' <>
        'https://kfwpqnxugybgcuhlqtci.supabase.co/storage/v1/object/public/documents/'
        || (image ->> 'path')
      or not exists (
        select 1
        from storage.objects object
        where object.bucket_id = 'documents'
          and object.name = image ->> 'path'
          and object.owner_id = v_user::text
      )
  ) then
    raise exception 'Invalid or missing uploaded image' using errcode = '42501';
  end if;

  if (
    select pg_catalog.count(distinct image ->> 'path')
    from pg_catalog.jsonb_array_elements(p_images) image
  ) <> jsonb_array_length(p_images) then
    raise exception 'Duplicate image path';
  end if;

  select pg_catalog.array_agg(image ->> 'url' order by ordinal)
  into v_image_urls
  from pg_catalog.jsonb_array_elements(p_images) with ordinality images(image, ordinal);

  select * into v_document
  from pg_catalog.jsonb_populate_record(null::public.tai_lieu, p_document);
  select * into v_post
  from pg_catalog.jsonb_populate_record(null::public.tin_dang, p_post);

  insert into public.tai_lieu(
    sinhvien_id,
    danhmuc,
    ten_sach,
    nam_xuat_ban,
    do_moi,
    ghi_chu_tinh_trang,
    gia_ban
  ) values (
    v_user,
    v_document.danhmuc,
    pg_catalog.btrim(v_document.ten_sach),
    v_document.nam_xuat_ban,
    v_document.do_moi,
    v_document.ghi_chu_tinh_trang,
    v_document.gia_ban
  ) returning * into v_document;

  insert into public.tin_dang(
    tailieu_id,
    nguoi_dang_id,
    ho_ten_nguoi_dang,
    tieu_de,
    noi_dung_mo_ta,
    dia_chi,
    hinh_anh,
    trang_thai_tin
  ) values (
    v_document.tailieu_id,
    v_user,
    v_student.ho_ten,
    pg_catalog.btrim(v_post.tieu_de),
    v_post.noi_dung_mo_ta,
    v_post.dia_chi,
    v_image_urls,
    'DaAn'
  ) returning * into v_post;

  insert into public.post_requests(request_id, sinhvien_id, tindang_id, payload)
  values(p_request_id, v_user, v_post.tindang_id, v_payload);

  return pg_catalog.to_jsonb(v_post)
    || pg_catalog.jsonb_build_object('tai_lieu', pg_catalog.to_jsonb(v_document));
end;
$$;

revoke all on function public.create_post(uuid, jsonb, jsonb, jsonb) from public, anon;
grant execute on function public.create_post(uuid, jsonb, jsonb, jsonb) to authenticated;

-- ─── 3. Admin Post Approval & Rejection RPCs ────────────────────────────────
create or replace function public.admin_get_pending_posts()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Admin access required' using errcode = '42501';
  end if;

  return coalesce((
    select pg_catalog.jsonb_agg(
      pg_catalog.to_jsonb(td) || pg_catalog.jsonb_build_object('tai_lieu', pg_catalog.to_jsonb(tl))
      order by td.ngay_tao asc
    )
    from public.tin_dang td
    join public.tai_lieu tl on tl.tailieu_id = td.tailieu_id
    where td.trang_thai_tin = 'DaAn'
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.admin_get_pending_posts() from public, anon;
grant execute on function public.admin_get_pending_posts() to authenticated;

create or replace function public.admin_approve_post(p_tindang_id integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post public.tin_dang%rowtype;
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Admin access required' using errcode = '42501';
  end if;

  select * into v_post
  from public.tin_dang
  where tindang_id = p_tindang_id;

  if not found then
    raise exception 'Không tìm thấy bài đăng.';
  end if;

  if v_post.trang_thai_tin <> 'DaAn' then
    raise exception 'Chỉ có thể duyệt bài đăng đang ở trạng thái chờ duyệt.';
  end if;

  update public.tin_dang
  set trang_thai_tin = 'DangHienThi'
  where tindang_id = p_tindang_id
  returning * into v_post;

  return pg_catalog.to_jsonb(v_post);
end;
$$;

revoke all on function public.admin_approve_post(integer) from public, anon;
grant execute on function public.admin_approve_post(integer) to authenticated;

create or replace function public.admin_reject_post(p_tindang_id integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post public.tin_dang%rowtype;
  v_img text;
  v_path text;
  v_paths text[] := '{}'::text[];
  v_prefix text := 'https://kfwpqnxugybgcuhlqtci.supabase.co/storage/v1/object/public/documents/';
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Admin access required' using errcode = '42501';
  end if;

  select * into v_post
  from public.tin_dang
  where tindang_id = p_tindang_id;

  if not found then
    raise exception 'Không tìm thấy bài đăng.';
  end if;

  if v_post.trang_thai_tin <> 'DaAn' then
    raise exception 'Chỉ có thể từ chối bài đăng đang ở trạng thái chờ duyệt.';
  end if;

  -- Extract relative image paths for storage cleanup
  if v_post.hinh_anh is not null then
    foreach v_img in array v_post.hinh_anh loop
      if v_img like v_prefix || '%' then
        v_path := substring(v_img from length(v_prefix) + 1);
        v_paths := array_append(v_paths, v_path);
      end if;
    end loop;
  end if;

  -- Delete associated reports, post requests, the post, and document
  delete from public.bao_cao_vi_pham where tindang_id = p_tindang_id;
  delete from public.post_requests where tindang_id = p_tindang_id;
  delete from public.tin_dang where tindang_id = p_tindang_id;
  delete from public.tai_lieu where tailieu_id = v_post.tailieu_id;

  return pg_catalog.jsonb_build_object(
    'tindang_id', p_tindang_id,
    'image_paths', pg_catalog.to_jsonb(v_paths)
  );
end;
$$;

revoke all on function public.admin_reject_post(integer) from public, anon;
grant execute on function public.admin_reject_post(integer) to authenticated;

-- Storage delete permission for admin to clean up rejected post images
drop policy if exists admin_storage_delete on storage.objects;
create policy admin_storage_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'documents' and public.is_admin());

-- ─── 4. Report Handling ─────────────────────────────────────────────────────
alter table public.bao_cao_vi_pham
  add column if not exists ngay_tao timestamptz not null default now();

create or replace function public.admin_get_reports(p_status text default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Admin access required' using errcode = '42501';
  end if;

  return coalesce((
    select pg_catalog.jsonb_agg(
      pg_catalog.jsonb_build_object(
        'baocao_id', r.baocao_id,
        'tindang_id', r.tindang_id,
        'nguoi_bao_cao', r.nguoi_bao_cao,
        'ten_nguoi_bao_cao', coalesce(reporter.ho_ten, 'Sinh viên'),
        'ly_do', r.ly_do,
        'chi_tiet', r.chi_tiet,
        'trang_thai_xl', r.trang_thai_xl::text,
        'ngay_tao', r.ngay_tao,
        'tieu_de_tin', td.tieu_de,
        'trang_thai_tin', td.trang_thai_tin,
        'hinh_anh_tin', td.hinh_anh,
        'nguoi_dang_id', td.nguoi_dang_id,
        'ho_ten_nguoi_dang', td.ho_ten_nguoi_dang
      )
      order by
        case r.trang_thai_xl::text
          when 'ChoXuLy' then 1
          when 'DaXuLy' then 2
          when 'BacBo' then 3
          else 4
        end asc,
        r.ngay_tao desc
    )
    from public.bao_cao_vi_pham r
    left join public.sinh_vien reporter on reporter.sinhvien_id = r.nguoi_bao_cao
    left join public.tin_dang td on td.tindang_id = r.tindang_id
    where (p_status is null or r.trang_thai_xl::text = p_status)
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.admin_get_reports(text) from public, anon;
grant execute on function public.admin_get_reports(text) to authenticated;

create or replace function public.admin_resolve_report(
  p_baocao_id integer,
  p_trang_thai text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_report public.bao_cao_vi_pham%rowtype;
begin
  if not public.is_admin() then
    raise exception 'Unauthorized: Admin access required' using errcode = '42501';
  end if;

  if p_trang_thai not in ('DaXuLy', 'BacBo') then
    raise exception 'Trạng thái xử lý không hợp lệ: %', p_trang_thai;
  end if;

  select * into v_report
  from public.bao_cao_vi_pham
  where baocao_id = p_baocao_id;

  if not found then
    raise exception 'Không tìm thấy báo cáo.';
  end if;

  if v_report.trang_thai_xl::text <> 'ChoXuLy' then
    raise exception 'Báo cáo này đã được xử lý trước đó.';
  end if;

  update public.bao_cao_vi_pham
  set trang_thai_xl = p_trang_thai::public.trang_thai_xu_ly_enum
  where baocao_id = p_baocao_id
  returning * into v_report;

  return pg_catalog.jsonb_build_object(
    'baocao_id', v_report.baocao_id,
    'tindang_id', v_report.tindang_id,
    'nguoi_bao_cao', v_report.nguoi_bao_cao,
    'ly_do', v_report.ly_do,
    'chi_tiet', v_report.chi_tiet,
    'trang_thai_xl', v_report.trang_thai_xl::text
  );
end;
$$;

revoke all on function public.admin_resolve_report(integer, text) from public, anon;
grant execute on function public.admin_resolve_report(integer, text) to authenticated;

-- ─── 5. Circulation Statistics Restriction ─────────────────────────────────
drop policy if exists thong_ke_read_all on public.thong_ke_luan_chuyen;
drop policy if exists thong_ke_admin_read on public.thong_ke_luan_chuyen;
create policy thong_ke_admin_read on public.thong_ke_luan_chuyen
  for select to authenticated using (public.is_admin());

create or replace function public.get_thong_ke_luan_chuyen()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  if not public.is_admin() then
    raise exception 'Unauthorized: Admin access required' using errcode = '42501';
  end if;

  return coalesce((
    select pg_catalog.jsonb_agg(
      pg_catalog.to_jsonb(t)
      order by
        split_part(t.ky_hoc, '-', 2)::int desc,
        case split_part(t.ky_hoc, '-', 1)
          when 'THU' then 3
          when 'HE' then 2
          else 1
        end desc
    )
    from public.thong_ke_luan_chuyen t
  ), '[]'::jsonb);
end;
$$;

commit;
