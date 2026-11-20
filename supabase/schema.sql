-- FIXWELL SERVICES INDIA: secure owner-scoped data schema
-- Run this in Supabase SQL Editor after creating a new FIXWELL-only project.
-- Every row belongs to one authenticated owner. RLS is enabled on every table.

create extension if not exists pgcrypto;

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text not null,
  location text,
  service text,
  source text,
  status text not null default 'New',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.quotations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  customer text not null,
  scope text not null,
  amount numeric(14,2) not null check (amount > 0),
  validity text not null default '7 days',
  terms text,
  status text not null default 'Pending approval'
    check (status in ('Pending approval','Approved','Rejected','Sent')),
  approved_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  service_type text,
  stage text not null default 'Planning',
  target_date date,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.payment_records (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  customer text not null,
  amount numeric(14,2) not null check (amount > 0),
  reference text,
  status text not null default 'Pending verification'
    check (status in ('Pending verification','Verified by owner','Rejected / not received')),
  verified_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists leads_owner_created_idx on public.leads(owner_id, created_at desc);
create index if not exists quotations_owner_created_idx on public.quotations(owner_id, created_at desc);
create index if not exists projects_owner_created_idx on public.projects(owner_id, created_at desc);
create index if not exists payments_owner_created_idx on public.payment_records(owner_id, created_at desc);

alter table public.leads enable row level security;
alter table public.quotations enable row level security;
alter table public.projects enable row level security;
alter table public.payment_records enable row level security;

drop policy if exists "Owner manages own leads" on public.leads;
create policy "Owner manages own leads" on public.leads
  for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

drop policy if exists "Owner manages own quotations" on public.quotations;
create policy "Owner manages own quotations" on public.quotations
  for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

drop policy if exists "Owner manages own projects" on public.projects;
create policy "Owner manages own projects" on public.projects
  for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

drop policy if exists "Owner manages own payment records" on public.payment_records;
create policy "Owner manages own payment records" on public.payment_records
  for all to authenticated using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

-- No public/anonymous access policies are created.
-- Do not expose a Supabase service-role key in browser code.
