-- Store document image URLs as an array and create the document/post atomically.
begin;

do $$
declare
  v_data_type text;
begin
  select c.data_type into v_data_type
  from information_schema.columns c
  where c.table_schema = 'public'
    and c.table_name = 'tin_dang'
    and c.column_name = 'hinh_anh';

  if v_data_type is null then
    raise exception 'Missing public.tin_dang.hinh_anh';
  end if;

  if v_data_type <> 'ARRAY' then
    execute 'alter table public.tin_dang alter column hinh_anh type text[]
      using case when nullif(hinh_anh::text, '''') is null
        then ''{}''::text[] else array[hinh_anh::text] end';
  end if;
end;
$$;

drop function if exists public.create_post(uuid, jsonb, jsonb, text, text);

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
    hinh_anh
  ) values (
    v_document.tailieu_id,
    v_user,
    v_student.ho_ten,
    pg_catalog.btrim(v_post.tieu_de),
    v_post.noi_dung_mo_ta,
    v_post.dia_chi,
    v_image_urls
  ) returning * into v_post;

  insert into public.post_requests(request_id, sinhvien_id, tindang_id, payload)
  values(p_request_id, v_user, v_post.tindang_id, v_payload);

  return pg_catalog.to_jsonb(v_post)
    || pg_catalog.jsonb_build_object('tai_lieu', pg_catalog.to_jsonb(v_document));
end;
$$;

revoke all on function public.create_post(uuid, jsonb, jsonb, jsonb)
  from public, anon;
grant execute on function public.create_post(uuid, jsonb, jsonb, jsonb)
  to authenticated;

create or replace function public.owns_document_path(p_path text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.sinh_vien student
    where student.sinhvien_id = auth.uid()
      and student.msv = pg_catalog.split_part(p_path, '/', 1)
      and p_path ~ (
        '^[A-Za-z0-9]+/[0-9a-f-]{36}/[0-9][.](jpg|png|webp|heic|heif)$'
      )
  );
$$;

create or replace function public.can_write_document_image(p_path text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.owns_document_path(p_path)
    and not exists (
      select 1
      from public.tin_dang post
      where (
        'https://kfwpqnxugybgcuhlqtci.supabase.co/storage/v1/object/public/documents/'
        || p_path
      ) = any(coalesce(post.hinh_anh, '{}'::text[]))
    );
$$;

drop policy if exists post_feature_storage_select on storage.objects;
drop policy if exists post_feature_storage_insert on storage.objects;
drop policy if exists post_feature_storage_update on storage.objects;
drop policy if exists post_feature_storage_delete on storage.objects;

create policy post_feature_storage_select
on storage.objects for select to authenticated
using(bucket_id = 'documents' and public.owns_document_path(name));

create policy post_feature_storage_insert
on storage.objects for insert to authenticated
with check(bucket_id = 'documents' and public.can_write_document_image(name));

create policy post_feature_storage_update
on storage.objects for update to authenticated
using(bucket_id = 'documents' and public.can_write_document_image(name))
with check(bucket_id = 'documents' and public.can_write_document_image(name));

create policy post_feature_storage_delete
on storage.objects for delete to authenticated
using(bucket_id = 'documents' and public.can_write_document_image(name));

commit;
