-- Migration: circulation_statistics
-- Periodic aggregation of completed document transactions per academic term (THU, XUAN, HE).

begin;

-- ─── 1. Table: thong_ke_luan_chuyen ──────────────────────────────────────────
create table if not exists public.thong_ke_luan_chuyen (
  thongke_id        serial primary key,
  ky_hoc            varchar(20) not null unique,
  tong_so_sach_ban  integer not null default 0 check (tong_so_sach_ban >= 0),
  tong_so_sach_tang integer not null default 0 check (tong_so_sach_tang >= 0),
  constraint thong_ke_tang_le_ban check (tong_so_sach_tang <= tong_so_sach_ban)
);

alter table public.thong_ke_luan_chuyen enable row level security;
revoke all on public.thong_ke_luan_chuyen from anon, authenticated;
grant select on public.thong_ke_luan_chuyen to authenticated;

drop policy if exists thong_ke_read_all on public.thong_ke_luan_chuyen;
create policy thong_ke_read_all on public.thong_ke_luan_chuyen
  for select to authenticated using (true);

-- ─── 2. Helper: map timestamp to academic term code (Asia/Ho_Chi_Minh) ───────
-- XUAN: Jan 1 – May 31
-- HE  : Jun 1 – Jul 31
-- THU : Aug 1 – Dec 31
create or replace function public.ky_hoc_of(p_ts timestamptz)
returns varchar(20)
language sql
stable
set search_path = ''
as $$
  select case
    when extract(month from p_ts at time zone 'Asia/Ho_Chi_Minh') between 1 and 5 then 'XUAN-'
    when extract(month from p_ts at time zone 'Asia/Ho_Chi_Minh') between 6 and 7 then 'HE-'
    else 'THU-'
  end || extract(year from p_ts at time zone 'Asia/Ho_Chi_Minh')::int::text;
$$;

-- ─── 3. Aggregation: recompute and upsert all terms (idempotent) ─────────────
create or replace function public.refresh_thong_ke_luan_chuyen()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.thong_ke_luan_chuyen (ky_hoc, tong_so_sach_ban, tong_so_sach_tang)
  select k.ky_hoc, coalesce(s.ban, 0), coalesce(s.tang, 0)
  from (
    select public.ky_hoc_of(gd.thoi_gian_dat) as ky_hoc
    from public.giao_dich gd
    where gd.trang_thai_gd = 'HoanTat'
    union
    select public.ky_hoc_of(now())
    union
    select ky_hoc from public.thong_ke_luan_chuyen
  ) k
  left join (
    select public.ky_hoc_of(gd.thoi_gian_dat) as ky_hoc,
           count(*)::int as ban,
           count(*) filter (where gd.tong_tien = 0)::int as tang
    from public.giao_dich gd
    where gd.trang_thai_gd = 'HoanTat'
    group by 1
  ) s on s.ky_hoc = k.ky_hoc
  on conflict (ky_hoc) do update
    set tong_so_sach_ban  = excluded.tong_so_sach_ban,
        tong_so_sach_tang = excluded.tong_so_sach_tang;
end;
$$;

revoke all on function public.refresh_thong_ke_luan_chuyen() from public, anon, authenticated;

-- ─── 4. RPC: get_thong_ke_luan_chuyen (newest term first) ────────────────────
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

revoke all on function public.get_thong_ke_luan_chuyen() from public, anon;
grant execute on function public.get_thong_ke_luan_chuyen() to authenticated;

-- ─── 5. Schedule daily refresh at 17:05 UTC (00:05 Asia/Ho_Chi_Minh) ─────────
create extension if not exists pg_cron;

select cron.unschedule(jobid)
from cron.job
where jobname = 'refresh-thong-ke-luan-chuyen';

select cron.schedule(
  'refresh-thong-ke-luan-chuyen',
  '5 17 * * *',
  $$select public.refresh_thong_ke_luan_chuyen()$$
);

-- ─── 6. Initial backfill ─────────────────────────────────────────────────────
select public.refresh_thong_ke_luan_chuyen();

commit;
