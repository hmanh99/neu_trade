-- Report a listing using the existing bao_cao_vi_pham table and
-- trang_thai_xu_ly_enum type. The RPC derives the reporter from auth.uid().
begin;

alter table public.bao_cao_vi_pham enable row level security;
revoke all on public.bao_cao_vi_pham from anon, authenticated;

create or replace function public.create_post_report(
  p_tindang_id integer,
  p_ly_do text,
  p_chi_tiet text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_post public.tin_dang%rowtype;
  v_report public.bao_cao_vi_pham%rowtype;
  v_detail text := nullif(pg_catalog.btrim(p_chi_tiet), '');
begin
  if v_user is null then
    raise exception 'Vui lòng đăng nhập để gửi báo cáo.' using errcode = '42501';
  end if;

  if nullif(pg_catalog.btrim(p_ly_do), '') is null
      or pg_catalog.char_length(p_ly_do) > 100 then
    raise exception 'Lý do báo cáo phải từ 1 đến 100 ký tự.';
  end if;
  if coalesce(pg_catalog.char_length(v_detail), 0) > 500 then
    raise exception 'Mô tả báo cáo không được quá 500 ký tự.';
  end if;
  if pg_catalog.btrim(p_ly_do) = 'Khác' and v_detail is null then
    raise exception 'Vui lòng mô tả chi tiết lý do báo cáo.';
  end if;

  select * into v_post
  from public.tin_dang
  where tindang_id = p_tindang_id;
  if not found then
    raise exception 'Không tìm thấy bài đăng.';
  end if;
  if v_post.nguoi_dang_id = v_user then
    raise exception 'Bạn không thể báo cáo bài đăng của chính mình.';
  end if;

  insert into public.bao_cao_vi_pham(
    tindang_id, nguoi_bao_cao, ly_do, chi_tiet
  ) values (
    p_tindang_id, v_user, pg_catalog.btrim(p_ly_do), v_detail
  )
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

revoke all on function public.create_post_report(integer, text, text)
  from public, anon;
grant execute on function public.create_post_report(integer, text, text)
  to authenticated;

commit;
