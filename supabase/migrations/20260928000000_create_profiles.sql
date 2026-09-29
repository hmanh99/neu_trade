create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  student_id text not null unique,
  full_name text not null,
  email text not null unique,
  phone text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_neu_email_check
    check (lower(email) ~ '^[a-z0-9._%+\-]+@st\.neu\.edu\.vn$')
);

alter table public.profiles enable row level security;

create policy "Users can read their own profile"
  on public.profiles for select
  using ((select auth.uid()) = user_id);

create policy "Users can create their own profile"
  on public.profiles for insert
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own profile"
  on public.profiles for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
