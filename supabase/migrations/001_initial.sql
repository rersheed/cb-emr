-- CB-EMR initial schema (PostgreSQL / Supabase)
-- App currently runs on DemoRepository; apply this when provisioning Supabase.

create extension if not exists "pgcrypto";

-- Geography
create table if not exists public.states (
  id text primary key,
  name text not null,
  code text not null unique
);

create table if not exists public.lgas (
  id text primary key,
  state_id text not null references public.states(id) on delete cascade,
  name text not null,
  code text
);

create index if not exists lgas_state_id_idx on public.lgas(state_id);

create table if not exists public.wards (
  id text primary key,
  lga_id text not null references public.lgas(id) on delete cascade,
  name text not null,
  code text,
  lat double precision,
  lon double precision
);

create index if not exists wards_lga_id_idx on public.wards(lga_id);

create table if not exists public.polling_units (
  id text primary key,
  ward_id text not null references public.wards(id) on delete cascade,
  name text not null,
  code text
);

create index if not exists polling_units_ward_id_idx on public.polling_units(ward_id);

-- Roles: field_agent | ward_supervisor | lga_supervisor | state_supervisor | situation_room | super_admin
create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  full_name text not null,
  role text not null,
  state_id text references public.states(id),
  lga_id text references public.lgas(id),
  ward_id text references public.wards(id),
  phone text,
  created_at timestamptz not null default now()
);

create table if not exists public.elections (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  election_date date not null,
  status text not null default 'active', -- draft|active|closed
  created_at timestamptz not null default now()
);

create table if not exists public.parties (
  id text primary key,
  name text not null,
  acronym text not null,
  color_hex text
);

-- Result status: draft|pending_ward|pending_lga|pending_state|state_verified|rejected
create table if not exists public.polling_results (
  id uuid primary key default gen_random_uuid(),
  election_id uuid not null references public.elections(id),
  polling_unit_id text not null references public.polling_units(id),
  submitted_by uuid not null references public.profiles(id),
  accredited_voters int not null default 0,
  valid_votes int not null default 0,
  invalid_votes int not null default 0,
  status text not null default 'draft',
  rejection_reason text,
  submitted_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (election_id, polling_unit_id)
);

create table if not exists public.result_details (
  id uuid primary key default gen_random_uuid(),
  result_id uuid not null references public.polling_results(id) on delete cascade,
  party_id text not null references public.parties(id),
  votes int not null default 0 check (votes >= 0),
  unique (result_id, party_id)
);

create table if not exists public.opening_reports (
  id uuid primary key default gen_random_uuid(),
  election_id uuid not null references public.elections(id),
  polling_unit_id text not null references public.polling_units(id),
  reporter_id uuid not null references public.profiles(id),
  opened_at timestamptz not null,
  materials_complete boolean not null default false,
  officials_present boolean not null default false,
  notes text,
  gps_lat double precision,
  gps_lon double precision,
  status text not null default 'pending_ward',
  created_at timestamptz not null default now()
);

create table if not exists public.incidents (
  id uuid primary key default gen_random_uuid(),
  election_id uuid not null references public.elections(id),
  polling_unit_id text not null references public.polling_units(id),
  reporter_id uuid not null references public.profiles(id),
  category text not null,
  description text not null,
  photo_path text,
  gps_lat double precision,
  gps_lon double precision,
  severity text not null default 'medium', -- low|medium|high|critical
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table if not exists public.approvals (
  id uuid primary key default gen_random_uuid(),
  result_id uuid not null references public.polling_results(id) on delete cascade,
  actor_id uuid not null references public.profiles(id),
  from_status text not null,
  to_status text not null,
  reason text,
  created_at timestamptz not null default now()
);

create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id),
  entity_type text not null,
  entity_id text not null,
  action text not null,
  meta jsonb,
  created_at timestamptz not null default now()
);

create index if not exists polling_results_status_idx on public.polling_results(status);
create index if not exists incidents_pu_idx on public.incidents(polling_unit_id);
create index if not exists audit_log_entity_idx on public.audit_log(entity_type, entity_id);

-- RLS outline (enable when wiring Auth)
-- alter table public.profiles enable row level security;
-- alter table public.polling_results enable row level security;
-- alter table public.incidents enable row level security;
-- alter table public.approvals enable row level security;
-- alter table public.audit_log enable row level security;
--
-- Policy sketches:
-- * Agents: SELECT/INSERT/UPDATE own results where status in (draft, rejected, pending_ward) and submitted_by = auth.uid()
-- * Ward supervisors: SELECT results in their ward; UPDATE status pending_ward -> pending_lga|rejected
-- * LGA supervisors: analogously for pending_lga
-- * State supervisors: pending_state -> state_verified|rejected
-- * Situation room: SELECT where status = 'state_verified' only
-- * Super admin: full access via role claim
-- * Geography tables: authenticated read-only
