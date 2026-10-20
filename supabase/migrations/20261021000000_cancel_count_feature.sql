-- Migration: cancel_count_feature
-- Adds cancellation tracking, cancel_transaction RPC, expire_transactions counter update,
-- and get_user_public_stats RPC for displaying user cancellation stats to others.

begin;

-- ─── 1. Columns for tracking cancellation on public.giao_dich ────────────────
alter table public.giao_dich
  add column if not exists nguoi_huy_id uuid references public.sinh_vien(sinhvien_id),
  add column if not exists ly_do_huy text,
  add column if not exists thoi_gian_huy timestamptz;

-- ─── 2. Ensure so_lan_huy_don column exists on public.sinh_vien ──────────────
alter table if exists public.sinh_vien
  add column if not exists so_lan_huy_don integer not null default 0;

-- ─── 3. RPC: cancel_transaction ──────────────────────────────────────────────
create or replace function public.cancel_transaction(
  p_giaodich_id integer,
  p_ly_do text default null
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
  v_reason text := nullif(pg_catalog.btrim(p_ly_do), '');
  v_result jsonb;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  -- Lock transaction record to prevent concurrent modifications
  select * into v_transaction
  from public.giao_dich
  where giaodich_id = p_giaodich_id
  for update;

  if not found then
    raise exception 'Giao dịch không tồn tại.';
  end if;

  if v_transaction.trang_thai_gd <> 'DangGiuCho' then
    raise exception 'Chỉ có thể hủy giao dịch đang trong trạng thái giữ chỗ.';
  end if;

  select * into v_post
  from public.tin_dang
  where tindang_id = v_transaction.tindang_id;

  if not found then
    raise exception 'Bài đăng liên quan không tồn tại.';
  end if;

  -- Verify caller is buyer or seller
  if v_user <> v_transaction.nguoi_mua_id and v_user <> v_post.nguoi_dang_id then
    raise exception 'Bạn không có quyền hủy giao dịch này.';
  end if;

  -- Update transaction to DaHuy
  update public.giao_dich
  set trang_thai_gd = 'DaHuy',
      nguoi_huy_id = v_user,
      ly_do_huy = v_reason,
      thoi_gian_huy = now()
  where giaodich_id = p_giaodich_id
  returning * into v_transaction;

  -- Increment cancel count for the user who initiated the cancellation
  update public.sinh_vien
  set so_lan_huy_don = coalesce(so_lan_huy_don, 0) + 1
  where sinhvien_id = v_user;

  -- Restore post status to 'DangHienThi' if no other active reservation exists
  if not exists (
    select 1 from public.giao_dich gd
    where gd.tindang_id = v_transaction.tindang_id
      and gd.trang_thai_gd = 'DangGiuCho'
  ) then
    update public.tin_dang
    set trang_thai_tin = 'DangHienThi'
    where tindang_id = v_transaction.tindang_id;
  end if;

  -- Return updated transaction object
  select pg_catalog.jsonb_build_object(
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
    'nguoi_huy_id', v_transaction.nguoi_huy_id,
    'ly_do_huy', v_transaction.ly_do_huy,
    'thoi_gian_huy', v_transaction.thoi_gian_huy,
    'da_danh_gia', false,
    'so_sao_cua_toi', null
  ) into v_result;

  return v_result;
end;
$$;

revoke all on function public.cancel_transaction(integer, text) from public, anon;
grant execute on function public.cancel_transaction(integer, text) to authenticated;

-- ─── 4. Update expire_transactions to record cancellation and increment counter ─
create or replace function public.expire_transactions()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_expired_post_ids integer[];
begin
  -- Collect post IDs from expired transactions
  select array_agg(distinct tindang_id)
  into v_expired_post_ids
  from public.giao_dich
  where trang_thai_gd = 'DangGiuCho'
    and thoi_gian_het_han < now();

  -- Increment cancel count for buyers of expired reservations (they reserved but did not complete in time)
  update public.sinh_vien sv
  set so_lan_huy_don = coalesce(sv.so_lan_huy_don, 0) + sub.expired_count
  from (
    select nguoi_mua_id, count(*) as expired_count
    from public.giao_dich
    where trang_thai_gd = 'DangGiuCho'
      and thoi_gian_het_han < now()
    group by nguoi_mua_id
  ) sub
  where sv.sinhvien_id = sub.nguoi_mua_id;

  -- Cancel expired transactions and set buyer as canceller with timeout reason
  update public.giao_dich
  set trang_thai_gd = 'DaHuy',
      nguoi_huy_id = nguoi_mua_id,
      ly_do_huy = 'Quá hạn giữ chỗ 48h',
      thoi_gian_huy = now()
  where trang_thai_gd = 'DangGiuCho'
    and thoi_gian_het_han < now();

  -- Restore posts to visible if no other active reservation exists
  if v_expired_post_ids is not null then
    update public.tin_dang
    set trang_thai_tin = 'DangHienThi'
    where tindang_id = any(v_expired_post_ids)
      and trang_thai_tin = 'DaDatGiu'
      and not exists (
        select 1 from public.giao_dich gd
        where gd.tindang_id = tin_dang.tindang_id
          and gd.trang_thai_gd = 'DangGiuCho'
      );
  end if;
end;
$$;

revoke all on function public.expire_transactions() from public, anon;
grant execute on function public.expire_transactions() to authenticated;

-- ─── 5. RPC: get_user_public_stats ───────────────────────────────────────────
create or replace function public.get_user_public_stats(
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
  v_cancel_count integer := 0;
  v_completed_count bigint := 0;
begin
  -- Rating summary
  select
    coalesce(round(avg(so_sao)::numeric, 1), 0),
    count(*)
  into v_avg, v_count
  from public.danh_gia
  where nguoi_nhan_danh_gia = p_sinhvien_id;

  -- Cancellation count from sinh_vien
  select coalesce(so_lan_huy_don, 0)
  into v_cancel_count
  from public.sinh_vien
  where sinhvien_id = p_sinhvien_id;

  -- Total completed transactions count
  select count(*)
  into v_completed_count
  from public.giao_dich gd
  join public.tin_dang td on td.tindang_id = gd.tindang_id
  where gd.trang_thai_gd = 'HoanTat'
    and (gd.nguoi_mua_id = p_sinhvien_id or td.nguoi_dang_id = p_sinhvien_id);

  return pg_catalog.jsonb_build_object(
    'sinhvien_id', p_sinhvien_id,
    'diem_trung_binh', v_avg,
    'tong_danh_gia', v_count,
    'so_lan_huy_don', coalesce(v_cancel_count, 0),
    'tong_hoan_tat', v_completed_count
  );
end;
$$;

revoke all on function public.get_user_public_stats(uuid) from public, anon;
grant execute on function public.get_user_public_stats(uuid) to authenticated;

-- ─── 6. UPDATE: get_my_transactions with cancellation details ────────────────
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
      gd.nguoi_huy_id,
      gd.ly_do_huy,
      gd.thoi_gian_huy,
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

-- ─── 7. UPDATE: get_transaction_detail with cancellation details ─────────────
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
      gd.nguoi_huy_id,
      gd.ly_do_huy,
      gd.thoi_gian_huy,
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

commit;
