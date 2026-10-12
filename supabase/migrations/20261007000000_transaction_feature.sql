-- Transaction feature: reservation, completion, and expiry logic.
begin;

-- ─── Table ──────────────────────────────────────────────────────────────
create table if not exists public.giao_dich (
  giaodich_id serial primary key,
  tindang_id integer not null references public.tin_dang(tindang_id),
  nguoi_mua_id uuid not null references public.sinh_vien(sinhvien_id),
  ten_nguoi_mua text not null,
  tong_tien numeric not null,
  dia_chi text,
  thoi_gian_dat timestamptz not null default now(),
  thoi_gian_het_han timestamptz not null default (now() + interval '48 hours'),
  trang_thai_gd text not null default 'DangGiuCho',
  note text
);

alter table public.giao_dich enable row level security;
grant select on public.giao_dich to authenticated;

-- Buyer can see own transactions
drop policy if exists transaction_buyer_read on public.giao_dich;
create policy transaction_buyer_read on public.giao_dich for select to authenticated
  using (nguoi_mua_id = (select auth.uid()));

-- Seller can see transactions on their posts
drop policy if exists transaction_seller_read on public.giao_dich;
create policy transaction_seller_read on public.giao_dich for select to authenticated
  using (
    exists (
      select 1 from public.tin_dang td
      where td.tindang_id = giao_dich.tindang_id
        and td.nguoi_dang_id = (select auth.uid())
    )
  );

-- Update tin_dang policy so buyers of transactions can also read the post
drop policy if exists post_feature_read_posts on public.tin_dang;
create policy post_feature_read_posts on public.tin_dang for select to authenticated
  using (
    trang_thai_tin = 'DangHienThi' or nguoi_dang_id = (select auth.uid())
    )
  );

-- ─── RPC: expire_transactions (called periodically or on-read) ─────────
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

  -- Cancel expired transactions
  update public.giao_dich
  set trang_thai_gd = 'DaHuy'
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

-- ─── RPC: create_transaction ────────────────────────────────────────────
create or replace function public.create_transaction(
  p_tindang_id integer,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_student public.sinh_vien%rowtype;
  v_post public.tin_dang%rowtype;
  v_document public.tai_lieu%rowtype;
  v_transaction public.giao_dich%rowtype;
  v_result jsonb;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  -- Auto-expire prior reservations
  perform public.expire_transactions();

  -- Lock to prevent double reservation
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('reserve_' || p_tindang_id::text, 0)
  );

  -- Fetch buyer info
  select * into v_student from public.sinh_vien where sinhvien_id = v_user;
  if not found then
    raise exception 'Student profile not found';
  end if;

  -- Fetch the post
  select * into v_post from public.tin_dang where tindang_id = p_tindang_id;
  if not found then
    raise exception 'Post not found';
  end if;

  -- Cannot reserve own post
  if v_post.nguoi_dang_id = v_user then
    raise exception 'Cannot reserve your own post';
  end if;

  -- Post must be visible
  if v_post.trang_thai_tin <> 'DangHienThi' then
    raise exception 'Post is not available for reservation';
  end if;

  -- Fetch document for price
  select * into v_document from public.tai_lieu where tailieu_id = v_post.tailieu_id;
  if not found then
    raise exception 'Document not found';
  end if;

  -- Create transaction
  insert into public.giao_dich (
    tindang_id, nguoi_mua_id, ten_nguoi_mua, tong_tien, dia_chi, note
  ) values (
    p_tindang_id,
    v_user,
    v_student.ho_ten,
    v_document.gia_ban,
    v_post.dia_chi,
    p_note
  ) returning * into v_transaction;

  -- Hide the post (DaDatGiu)
  update public.tin_dang
  set trang_thai_tin = 'DaDatGiu'
  where tindang_id = p_tindang_id;

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
    'hinh_anh', v_post.hinh_anh
  ) into v_result;

  return v_result;
end;
$$;

revoke all on function public.create_transaction(integer, text) from public, anon;
grant execute on function public.create_transaction(integer, text) to authenticated;

-- ─── RPC: complete_transaction ──────────────────────────────────────────
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
    'hinh_anh', v_post.hinh_anh
  ) into v_result;

  return v_result;
end;
$$;

revoke all on function public.complete_transaction(integer) from public, anon;
grant execute on function public.complete_transaction(integer) to authenticated;

-- ─── RPC: get_my_transactions ───────────────────────────────────────────
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
      td.hinh_anh
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

-- ─── RPC: get_transaction_detail ────────────────────────────────────────
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
      td.hinh_anh
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
