-- Requires the existing sinh_vien, tai_lieu and tin_dang tables.
-- Run this migration in the Supabase SQL editor before using the feature.
begin;

-- Internal receipt for safe retries after a lost response. Business tables retain their schema.
create table if not exists public.post_requests (
  request_id uuid not null,
  sinhvien_id uuid not null references public.sinh_vien(sinhvien_id),
  tindang_id integer not null references public.tin_dang(tindang_id) on delete cascade,
  payload jsonb not null,
  primary key (sinhvien_id, request_id)
);
alter table public.post_requests enable row level security;
revoke all on public.post_requests from anon, authenticated;

create or replace function public.get_post_options()
returns jsonb language sql stable security definer set search_path = '' as $$
  select pg_catalog.jsonb_build_object(
    'categories', (
      select pg_catalog.jsonb_agg(e.enumlabel order by e.enumsortorder)
      from pg_catalog.pg_enum e join pg_catalog.pg_attribute a on a.atttypid = e.enumtypid
      where a.attrelid = 'public.tai_lieu'::regclass and a.attname = 'danhmuc'
    ),
    'conditions', (
      select pg_catalog.jsonb_agg(e.enumlabel order by e.enumsortorder)
      from pg_catalog.pg_enum e join pg_catalog.pg_attribute a on a.atttypid = e.enumtypid
      where a.attrelid = 'public.tai_lieu'::regclass and a.attname = 'do_moi'
    ),
    'name_max_length', (select character_maximum_length from information_schema.columns
      where table_schema = 'public' and table_name = 'tai_lieu' and column_name = 'ten_sach'),
    'condition_note_max_length', (select character_maximum_length from information_schema.columns
      where table_schema = 'public' and table_name = 'tai_lieu' and column_name = 'ghi_chu_tinh_trang'),
    'price_precision', (select numeric_precision from information_schema.columns
      where table_schema = 'public' and table_name = 'tai_lieu' and column_name = 'gia_ban'),
    'price_scale', (select numeric_scale from information_schema.columns
      where table_schema = 'public' and table_name = 'tai_lieu' and column_name = 'gia_ban'),
    'year_required', (select is_nullable = 'NO' from information_schema.columns
      where table_schema = 'public' and table_name = 'tai_lieu' and column_name = 'nam_xuat_ban'),
    'condition_note_required', (select is_nullable = 'NO' from information_schema.columns
      where table_schema = 'public' and table_name = 'tai_lieu' and column_name = 'ghi_chu_tinh_trang'),
    'image_required', (select is_nullable = 'NO' from information_schema.columns
      where table_schema = 'public' and table_name = 'tin_dang' and column_name = 'hinh_anh'),
    'address_required', (select is_nullable = 'NO' from information_schema.columns
      where table_schema = 'public' and table_name = 'tin_dang' and column_name = 'dia_chi'),
    'description_required', (select is_nullable = 'NO' from information_schema.columns
      where table_schema = 'public' and table_name = 'tin_dang' and column_name = 'noi_dung_mo_ta')
  ) where auth.uid() is not null;
$$;

create or replace function public.get_post_result(p_request_id uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_result jsonb; v_user uuid := auth.uid();
begin
  if v_user is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || p_request_id::text, 0));
  select pg_catalog.to_jsonb(td) || pg_catalog.jsonb_build_object('tai_lieu', pg_catalog.to_jsonb(tl))
    into v_result
    from public.post_requests r
    join public.tin_dang td on td.tindang_id = r.tindang_id
    join public.tai_lieu tl on tl.tailieu_id = td.tailieu_id
    where r.sinhvien_id = v_user and r.request_id = p_request_id;
  return v_result;
end;
$$;

create or replace function public.create_post(
  p_request_id uuid, p_document jsonb, p_post jsonb,
  p_image_path text default null, p_image_url text default null
)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := auth.uid();
  v_student public.sinh_vien%rowtype;
  v_document public.tai_lieu%rowtype;
  v_post public.tin_dang%rowtype;
  v_payload jsonb;
  v_existing public.post_requests%rowtype;
begin
  if v_user is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  if p_request_id is null then raise exception 'Missing request ID'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || p_request_id::text, 0));
  v_payload := pg_catalog.jsonb_build_object('document', p_document, 'post', p_post,
    'image_path', p_image_path, 'image_url', p_image_url);
  select * into v_existing from public.post_requests
    where sinhvien_id = v_user and request_id = p_request_id;
  if found then
    if v_existing.payload <> v_payload then raise exception 'Request payload changed'; end if;
    return public.get_post_result(p_request_id);
  end if;

  select * into v_student from public.sinh_vien where sinhvien_id = v_user;
  if not found or nullif(btrim(v_student.msv), '') is null or nullif(btrim(v_student.ho_ten), '') is null then
    raise exception 'Complete student profile first';
  end if;
  if v_student.msv !~ '^[A-Za-z0-9]+$' then raise exception 'Invalid student code'; end if;
  if coalesce(char_length(btrim(p_post ->> 'tieu_de')), 0) not between 1 and 255 then
    raise exception 'Invalid title';
  end if;
  if coalesce(char_length(btrim(p_post ->> 'dia_chi')), 0) > 50 then raise exception 'Invalid address'; end if;
  if coalesce(char_length(btrim(p_document ->> 'ten_sach')), 0) = 0 then raise exception 'Missing document name'; end if;
  if (p_document ->> 'gia_ban') is null or (p_document ->> 'gia_ban')::numeric < 0 then
    raise exception 'Invalid price';
  end if;
  if (p_document ->> 'nam_xuat_ban') is not null and
    ((p_document ->> 'nam_xuat_ban')::integer < 1 or
     (p_document ->> 'nam_xuat_ban')::integer > extract(year from current_date)::integer) then
    raise exception 'Invalid publication year';
  end if;
  if (p_image_path is null) <> (p_image_url is null) then raise exception 'Invalid image'; end if;
  if p_image_path is not null then
    if p_image_path !~ ('^' || v_student.msv || '/' || p_request_id::text || '\.(jpg|png|webp|heic|heif)$') then
      raise exception 'Invalid image path';
    end if;
    -- Project-specific public URL; update this origin if moving to another Supabase project.
    if p_image_url <> 'https://kfwpqnxugybgcuhlqtci.supabase.co/storage/v1/object/public/documents/' || p_image_path then
      raise exception 'Invalid public image URL';
    end if;
    if not exists (select 1 from storage.objects where bucket_id = 'documents'
      and name = p_image_path and owner_id = v_user::text) then
      raise exception 'Uploaded image not found' using errcode = '42501';
    end if;
  end if;

  -- Populate a typed record so existing enums, varchar limits and numeric types apply.
  select * into v_document from pg_catalog.jsonb_populate_record(null::public.tai_lieu, p_document);
  select * into v_post from pg_catalog.jsonb_populate_record(null::public.tin_dang, p_post);
  insert into public.tai_lieu(sinhvien_id, danhmuc, ten_sach, nam_xuat_ban, do_moi, ghi_chu_tinh_trang, gia_ban)
    values(v_user, v_document.danhmuc, btrim(v_document.ten_sach), v_document.nam_xuat_ban,
      v_document.do_moi, v_document.ghi_chu_tinh_trang, v_document.gia_ban)
    returning * into v_document;
  insert into public.tin_dang(tailieu_id, nguoi_dang_id, ho_ten_nguoi_dang,
    tieu_de, noi_dung_mo_ta, dia_chi, hinh_anh)
    values(v_document.tailieu_id, v_user, v_student.ho_ten,
      btrim(v_post.tieu_de), v_post.noi_dung_mo_ta, v_post.dia_chi,
      case when p_image_url is null then '{}'::text[] else array[p_image_url] end)
    returning * into v_post;
  insert into public.post_requests(request_id, sinhvien_id, tindang_id, payload)
    values(p_request_id, v_user, v_post.tindang_id, v_payload);
  return pg_catalog.to_jsonb(v_post) || pg_catalog.jsonb_build_object('tai_lieu', pg_catalog.to_jsonb(v_document));
end;
$$;

revoke all on function public.get_post_options() from public, anon;
revoke all on function public.get_post_result(uuid) from public, anon;
revoke all on function public.create_post(uuid,jsonb,jsonb,text,text) from public, anon;
grant execute on function public.get_post_options() to authenticated;
grant execute on function public.get_post_result(uuid) to authenticated;
grant execute on function public.create_post(uuid,jsonb,jsonb,text,text) to authenticated;

alter table public.tin_dang enable row level security;
alter table public.tai_lieu enable row level security;
grant select on public.tin_dang, public.tai_lieu to authenticated;
drop policy if exists post_feature_read_posts on public.tin_dang;
create policy post_feature_read_posts on public.tin_dang for select to authenticated
  using (trang_thai_tin = 'DangHienThi' or nguoi_dang_id = (select auth.uid()));
-- Avoid querying tin_dang here, which would create a recursive RLS dependency.
drop policy if exists post_feature_read_documents on public.tai_lieu;
create policy post_feature_read_documents on public.tai_lieu for select to authenticated using (true);

-- Public downloads; writes are still authenticated and scoped by student code.
insert into storage.buckets(id, name, public) values ('documents', 'documents', true)
  on conflict (id) do update set public = true;

create or replace function public.owns_document_path(p_path text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.sinh_vien sv
    where sv.sinhvien_id = auth.uid() and sv.msv = split_part(p_path, '/', 1)
      and p_path ~ '^[A-Za-z0-9]+/[0-9a-f-]{36}\.(jpg|png|webp|heic|heif)$');
$$;
create or replace function public.can_write_document_image(p_path text)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.owns_document_path(p_path) and not exists (
    select 1 from public.tin_dang where
      'https://kfwpqnxugybgcuhlqtci.supabase.co/storage/v1/object/public/documents/' || p_path
      = any(coalesce(hinh_anh, '{}'::text[]))
  );
$$;
revoke all on function public.owns_document_path(text) from public, anon;
revoke all on function public.can_write_document_image(text) from public, anon;
grant execute on function public.owns_document_path(text) to authenticated;
grant execute on function public.can_write_document_image(text) to authenticated;
drop policy if exists post_feature_storage_select on storage.objects;
drop policy if exists post_feature_storage_insert on storage.objects;
drop policy if exists post_feature_storage_update on storage.objects;
drop policy if exists post_feature_storage_delete on storage.objects;
create policy post_feature_storage_select on storage.objects for select to authenticated
  using(bucket_id = 'documents' and public.owns_document_path(name));
create policy post_feature_storage_insert on storage.objects for insert to authenticated
  with check(bucket_id = 'documents' and public.can_write_document_image(name));
create policy post_feature_storage_update on storage.objects for update to authenticated
  using(bucket_id = 'documents' and public.can_write_document_image(name))
  with check(bucket_id = 'documents' and public.can_write_document_image(name));
create policy post_feature_storage_delete on storage.objects for delete to authenticated
  using(bucket_id = 'documents' and public.can_write_document_image(name));
commit;
