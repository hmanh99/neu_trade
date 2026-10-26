-- Migration: post_history_feature
-- Owner RPCs for updating and deleting own posts in Post History.

begin;

create or replace function public.update_my_post(
  p_tindang_id integer,
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
  v_old_urls text[];
  v_image_urls text[];
  v_old_url text;
  v_removed_paths text[] := '{}'::text[];
  v_prefix text := 'https://kfwpqnxugybgcuhlqtci.supabase.co/storage/v1/object/public/documents/';
begin
  if v_user is null then
    raise exception 'Vui lòng đăng nhập để thực hiện thao tác này.' using errcode = '42501';
  end if;

  if p_tindang_id is null then
    raise exception 'Thiếu mã bài đăng.';
  end if;

  select * into v_post
  from public.tin_dang
  where tindang_id = p_tindang_id
  for update;

  if not found then
    raise exception 'Không tìm thấy bài đăng.';
  end if;

  if v_post.nguoi_dang_id <> v_user then
    raise exception 'Bạn không có quyền chỉnh sửa bài đăng này.' using errcode = '42501';
  end if;

  if v_post.trang_thai_tin not in ('DaAn', 'DangHienThi') then
    raise exception 'Không thể chỉnh sửa bài đăng đang được đặt giữ hoặc đã bán.';
  end if;

  if p_images is null
      or jsonb_typeof(p_images) <> 'array'
      or jsonb_array_length(p_images) not between 1 and 10 then
    raise exception 'Cần từ 1 đến 10 hình ảnh cho bài đăng.';
  end if;

  select * into v_student
  from public.sinh_vien
  where sinhvien_id = v_user;

  if not found
      or nullif(pg_catalog.btrim(v_student.msv), '') is null
      or nullif(pg_catalog.btrim(v_student.ho_ten), '') is null then
    raise exception 'Vui lòng hoàn thiện hồ sơ sinh viên trước.';
  end if;

  if v_student.msv !~ '^[A-Za-z0-9]+$' then
    raise exception 'Mã sinh viên không hợp lệ.';
  end if;

  if coalesce(pg_catalog.char_length(pg_catalog.btrim(p_post ->> 'tieu_de')), 0)
      not between 1 and 255 then
    raise exception 'Tiêu đề bài đăng không hợp lệ.';
  end if;

  if coalesce(pg_catalog.char_length(pg_catalog.btrim(p_post ->> 'dia_chi')), 0) > 50 then
    raise exception 'Địa điểm giao dịch không hợp lệ.';
  end if;

  if coalesce(pg_catalog.char_length(pg_catalog.btrim(p_document ->> 'ten_sach')), 0) = 0 then
    raise exception 'Vui lòng nhập tên tài liệu.';
  end if;

  if (p_document ->> 'gia_ban') is null
      or (p_document ->> 'gia_ban')::numeric < 0 then
    raise exception 'Giá bán không hợp lệ.';
  end if;

  if (p_document ->> 'nam_xuat_ban') is not null
      and ((p_document ->> 'nam_xuat_ban')::integer < 1
        or (p_document ->> 'nam_xuat_ban')::integer
          > pg_catalog.date_part('year', current_date)::integer) then
    raise exception 'Năm xuất bản không hợp lệ.';
  end if;

  v_old_urls := coalesce(v_post.hinh_anh, '{}'::text[]);

  if exists (
    select 1
    from pg_catalog.jsonb_array_elements(p_images) image
    where image ->> 'url' is null
      or (
        -- Existing image retained from current post
        (image ->> 'path' is null or pg_catalog.btrim(image ->> 'path') = '')
        and not ((image ->> 'url') = any(v_old_urls))
      )
      or (
        -- Newly uploaded image
        (image ->> 'path' is not null and pg_catalog.btrim(image ->> 'path') <> '')
        and (
          (image ->> 'path') !~ (
            '^' || v_student.msv || '/[0-9a-f-]{36}/[0-9][.](jpg|png|webp|heic|heif)$'
          )
          or (image ->> 'url') <> v_prefix || (image ->> 'path')
          or not exists (
            select 1
            from storage.objects object
            where object.bucket_id = 'documents'
              and object.name = image ->> 'path'
              and object.owner_id = v_user::text
          )
        )
      )
  ) then
    raise exception 'Hình ảnh bài đăng không hợp lệ hoặc không tồn tại.' using errcode = '42501';
  end if;

  if (
    select pg_catalog.count(distinct image ->> 'url')
    from pg_catalog.jsonb_array_elements(p_images) image
  ) <> jsonb_array_length(p_images) then
    raise exception 'Danh sách hình ảnh bị trùng lặp.';
  end if;

  select pg_catalog.array_agg(image ->> 'url' order by ordinal)
  into v_image_urls
  from pg_catalog.jsonb_array_elements(p_images) with ordinality images(image, ordinal);

  foreach v_old_url in array v_old_urls loop
    if not (v_old_url = any(v_image_urls)) and v_old_url like v_prefix || '%' then
      v_removed_paths := array_append(
        v_removed_paths,
        substring(v_old_url from length(v_prefix) + 1)
      );
    end if;
  end loop;

  select * into v_document
  from pg_catalog.jsonb_populate_record(null::public.tai_lieu, p_document);
  select * into v_post
  from pg_catalog.jsonb_populate_record(null::public.tin_dang, p_post);

  update public.tai_lieu
  set
    danhmuc = v_document.danhmuc,
    ten_sach = pg_catalog.btrim(v_document.ten_sach),
    nam_xuat_ban = v_document.nam_xuat_ban,
    do_moi = v_document.do_moi,
    ghi_chu_tinh_trang = v_document.ghi_chu_tinh_trang,
    gia_ban = v_document.gia_ban
  where tailieu_id = (
    select tailieu_id from public.tin_dang where tindang_id = p_tindang_id
  )
  returning * into v_document;

  update public.tin_dang
  set
    ho_ten_nguoi_dang = v_student.ho_ten,
    tieu_de = pg_catalog.btrim(v_post.tieu_de),
    noi_dung_mo_ta = v_post.noi_dung_mo_ta,
    dia_chi = v_post.dia_chi,
    hinh_anh = v_image_urls,
    trang_thai_tin = 'DaAn'
  where tindang_id = p_tindang_id
  returning * into v_post;

  return pg_catalog.to_jsonb(v_post)
    || pg_catalog.jsonb_build_object(
      'tai_lieu', pg_catalog.to_jsonb(v_document),
      'removed_image_paths', pg_catalog.to_jsonb(v_removed_paths)
    );
end;
$$;

revoke all on function public.update_my_post(integer, jsonb, jsonb, jsonb) from public, anon;
grant execute on function public.update_my_post(integer, jsonb, jsonb, jsonb) to authenticated;

create or replace function public.delete_my_post(p_tindang_id integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_post public.tin_dang%rowtype;
  v_img text;
  v_path text;
  v_paths text[] := '{}'::text[];
  v_prefix text := 'https://kfwpqnxugybgcuhlqtci.supabase.co/storage/v1/object/public/documents/';
begin
  if v_user is null then
    raise exception 'Vui lòng đăng nhập để thực hiện thao tác này.' using errcode = '42501';
  end if;

  select * into v_post
  from public.tin_dang
  where tindang_id = p_tindang_id
  for update;

  if not found then
    raise exception 'Không tìm thấy bài đăng.';
  end if;

  if v_post.nguoi_dang_id <> v_user then
    raise exception 'Bạn không có quyền xoá bài đăng này.' using errcode = '42501';
  end if;

  if v_post.trang_thai_tin not in ('DaAn', 'DangHienThi') then
    raise exception 'Không thể xoá bài đăng đang được đặt giữ hoặc đã bán.';
  end if;

  if exists (
    select 1
    from public.giao_dich
    where tindang_id = p_tindang_id
      and trang_thai_gd in ('DangGiuCho', 'HoanThanh')
  ) then
    raise exception 'Không thể xoá bài đăng đã có giao dịch đặt giữ hoặc hoàn thành.';
  end if;

  if v_post.hinh_anh is not null then
    foreach v_img in array v_post.hinh_anh loop
      if v_img like v_prefix || '%' then
        v_path := substring(v_img from length(v_prefix) + 1);
        v_paths := array_append(v_paths, v_path);
      end if;
    end loop;
  end if;

  delete from public.giao_dich where tindang_id = p_tindang_id;
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

revoke all on function public.delete_my_post(integer) from public, anon;
grant execute on function public.delete_my_post(integer) to authenticated;

commit;
