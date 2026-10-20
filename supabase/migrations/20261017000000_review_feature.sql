-- Review feature: post-transaction rating and reviews.
begin;

-- ─── Table: danh_gia ────────────────────────────────────────────────────────
create table if not exists public.danh_gia (
  danhgia_id          integer generated always as identity primary key,
  giaodich_id         integer not null references public.giao_dich(giaodich_id) on delete cascade,
  nguoi_danh_gia      uuid not null references public.sinh_vien(sinhvien_id),
  nguoi_nhan_danh_gia uuid not null references public.sinh_vien(sinhvien_id),
  so_sao              smallint not null check (so_sao between 1 and 5),
  noi_dung            varchar(255),
  ngay_tao            timestamptz not null default now(),
  constraint danh_gia_once_per_reviewer unique (giaodich_id, nguoi_danh_gia),
  constraint danh_gia_not_self check (nguoi_danh_gia <> nguoi_nhan_danh_gia)
);

create index if not exists danh_gia_receiver_idx on public.danh_gia(nguoi_nhan_danh_gia);
create index if not exists danh_gia_transaction_idx on public.danh_gia(giaodich_id);

alter table public.danh_gia enable row level security;
revoke all on public.danh_gia from anon, authenticated;

-- ─── RPC: create_review ─────────────────────────────────────────────────────
create or replace function public.create_review(
  p_giaodich_id integer,
  p_so_sao integer,
  p_noi_dung text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_transaction public.giao_dich%rowtype;
  v_post public.tin_dang%rowtype;
  v_target_user uuid;
  v_content text := nullif(pg_catalog.btrim(p_noi_dung), '');
  v_review public.danh_gia%rowtype;
begin
  if v_user is null then
    raise exception 'Vui lòng đăng nhập để thực hiện đánh giá.' using errcode = '42501';
  end if;

  if p_so_sao is null or p_so_sao < 1 or p_so_sao > 5 then
    raise exception 'Số sao đánh giá phải từ 1 đến 5 sao.';
  end if;

  if coalesce(pg_catalog.char_length(v_content), 0) > 255 then
    raise exception 'Nội dung nhận xét tối đa 255 ký tự.';
  end if;

  -- Lock transaction record to prevent concurrency issues
  select * into v_transaction
  from public.giao_dich
  where giaodich_id = p_giaodich_id
  for update;

  if not found then
    raise exception 'Không tìm thấy giao dịch.';
  end if;

  if v_transaction.trang_thai_gd <> 'HoanTat' then
    raise exception 'Chỉ có thể đánh giá sau khi giao dịch đã hoàn tất.';
  end if;

  -- Find post to determine seller
  select * into v_post
  from public.tin_dang
  where tindang_id = v_transaction.tindang_id;

  if not found then
    raise exception 'Không tìm thấy thông tin bài đăng.';
  end if;

  -- Determine who is being rated
  if v_user = v_transaction.nguoi_mua_id then
    v_target_user := v_post.nguoi_dang_id;
  elsif v_user = v_post.nguoi_dang_id then
    v_target_user := v_transaction.nguoi_mua_id;
  else
    raise exception 'Bạn không thuộc giao dịch này.';
  end if;

  -- Check if already reviewed
  if exists (
    select 1 from public.danh_gia
    where giaodich_id = p_giaodich_id
      and nguoi_danh_gia = v_user
  ) then
    raise exception 'Bạn đã đánh giá giao dịch này rồi.';
  end if;

  insert into public.danh_gia (
    giaodich_id,
    nguoi_danh_gia,
    nguoi_nhan_danh_gia,
    so_sao,
    noi_dung
  ) values (
    p_giaodich_id,
    v_user,
    v_target_user,
    p_so_sao::smallint,
    v_content
  )
  returning * into v_review;

  return pg_catalog.jsonb_build_object(
    'danhgia_id', v_review.danhgia_id,
    'giaodich_id', v_review.giaodich_id,
    'nguoi_danh_gia', v_review.nguoi_danh_gia,
    'nguoi_nhan_danh_gia', v_review.nguoi_nhan_danh_gia,
    'so_sao', v_review.so_sao,
    'noi_dung', v_review.noi_dung,
    'ngay_tao', v_review.ngay_tao
  );
end;
$$;

revoke all on function public.create_review(integer, integer, text) from public, anon;
grant execute on function public.create_review(integer, integer, text) to authenticated;

-- ─── RPC: get_rating_summary ────────────────────────────────────────────────
create or replace function public.get_rating_summary(
  p_sinhvien_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_avg numeric;
  v_count bigint;
begin
  select
    coalesce(round(avg(so_sao)::numeric, 1), 0),
    count(*)
  into v_avg, v_count
  from public.danh_gia
  where nguoi_nhan_danh_gia = p_sinhvien_id;

  return pg_catalog.jsonb_build_object(
    'sinhvien_id', p_sinhvien_id,
    'diem_trung_binh', v_avg,
    'tong_danh_gia', v_count
  );
end;
$$;

revoke all on function public.get_rating_summary(uuid) from public, anon;
grant execute on function public.get_rating_summary(uuid) to authenticated;

-- ─── UPDATE: get_my_transactions ────────────────────────────────────────────
create or replace function public.get_my_transactions()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_result jsonb;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  -- Auto-expire before fetching
  perform public.expire_transactions();

  select pg_catalog.jsonb_agg(row_to_json(t)::jsonb order by t.thoi_gian_dat desc)
  into v_result
  from (
    select
      gd.giaodich_id,
      gd.tindang_id,
      gd.nguoi_mua_id,
      gd.ten_nguoi_mua,
      gd.tong_tien,
      gd.dia_chi,
      gd.thoi_gian_dat,
      gd.thoi_gian_het_han,
      gd.trang_thai_gd,
      gd.note,
      td.tieu_de as tieu_de_tin,
      td.nguoi_dang_id,
      td.ho_ten_nguoi_dang as ten_nguoi_ban,
      td.hinh_anh,
      exists(
        select 1 from public.danh_gia dg
        where dg.giaodich_id = gd.giaodich_id
          and dg.nguoi_danh_gia = v_user
      ) as da_danh_gia,
      (
        select dg.so_sao from public.danh_gia dg
        where dg.giaodich_id = gd.giaodich_id
          and dg.nguoi_danh_gia = v_user
        limit 1
      ) as so_sao_cua_toi
    from public.giao_dich gd
    join public.tin_dang td on td.tindang_id = gd.tindang_id
    where gd.nguoi_mua_id = v_user
      or td.nguoi_dang_id = v_user
  ) t;

  return coalesce(v_result, '[]'::jsonb);
end;
$$;

revoke all on function public.get_my_transactions() from public, anon;
grant execute on function public.get_my_transactions() to authenticated;

-- ─── UPDATE: get_transaction_detail ─────────────────────────────────────────
create or replace function public.get_transaction_detail(
  p_giaodich_id integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_result jsonb;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  -- Auto-expire before fetching
  perform public.expire_transactions();

  select row_to_json(t)::jsonb
  into v_result
  from (
    select
      gd.giaodich_id,
      gd.tindang_id,
      gd.nguoi_mua_id,
      gd.ten_nguoi_mua,
      gd.tong_tien,
      gd.dia_chi,
      gd.thoi_gian_dat,
      gd.thoi_gian_het_han,
      gd.trang_thai_gd,
      gd.note,
      td.tieu_de as tieu_de_tin,
      td.nguoi_dang_id,
      td.ho_ten_nguoi_dang as ten_nguoi_ban,
      td.hinh_anh,
      exists(
        select 1 from public.danh_gia dg
        where dg.giaodich_id = gd.giaodich_id
          and dg.nguoi_danh_gia = v_user
      ) as da_danh_gia,
      (
        select dg.so_sao from public.danh_gia dg
        where dg.giaodich_id = gd.giaodich_id
          and dg.nguoi_danh_gia = v_user
        limit 1
      ) as so_sao_cua_toi
    from public.giao_dich gd
    join public.tin_dang td on td.tindang_id = gd.tindang_id
    where gd.giaodich_id = p_giaodich_id
      and (gd.nguoi_mua_id = v_user or td.nguoi_dang_id = v_user)
  ) t;

  if v_result is null then
    raise exception 'Transaction not found or access denied';
  end if;

  return v_result;
end;
$$;

revoke all on function public.get_transaction_detail(integer) from public, anon;
grant execute on function public.get_transaction_detail(integer) to authenticated;

-- ─── UPDATE: complete_transaction ───────────────────────────────────────────
create or replace function public.complete_transaction(
  p_giaodich_id integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_transaction public.giao_dich%rowtype;
  v_post public.tin_dang%rowtype;
  v_result jsonb;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  select * into v_transaction from public.giao_dich where giaodich_id = p_giaodich_id;
  if not found then
    raise exception 'Transaction not found';
  end if;

  -- Only the seller can complete
  select * into v_post from public.tin_dang where tindang_id = v_transaction.tindang_id;
  if v_post.nguoi_dang_id <> v_user then
    raise exception 'Only the seller can complete this transaction';
  end if;

  if v_transaction.trang_thai_gd <> 'DangGiuCho' then
    raise exception 'Transaction is not in a reservable state';
  end if;

  -- Complete the transaction
  update public.giao_dich
  set trang_thai_gd = 'HoanTat'
  where giaodich_id = p_giaodich_id
  returning * into v_transaction;

  -- Mark the post as sold (DaBan)
  update public.tin_dang
  set trang_thai_tin = 'DaBan'
  where tindang_id = v_transaction.tindang_id;

  -- Build full response
  select jsonb_build_object(
    'giaodich_id', v_transaction.giaodich_id,
    'tindang_id', v_transaction.tindang_id,
    'nguoi_mua_id', v_transaction.nguoi_mua_id,
    'ten_nguoi_mua', v_transaction.ten_nguoi_mua,
    'tong_tien', v_transaction.tong_tien,
    'dia_chi', v_transaction.dia_chi,
    'thoi_gian_dat', v_transaction.thoi_gian_dat,
    'thoi_gian_het_han', v_transaction.thoi_gian_het_han,
    'trang_thai_gd', v_transaction.trang_thai_gd,
    'note', v_transaction.note,
    'tieu_de_tin', v_post.tieu_de,
    'nguoi_dang_id', v_post.nguoi_dang_id,
    'ten_nguoi_ban', v_post.ho_ten_nguoi_dang,
    'hinh_anh', v_post.hinh_anh,
    'da_danh_gia', false,
    'so_sao_cua_toi', null
  ) into v_result;

  return v_result;
end;
$$;

revoke all on function public.complete_transaction(integer) from public, anon;
grant execute on function public.complete_transaction(integer) to authenticated;

commit;
