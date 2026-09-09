-- PSG CRM — Supabase schema
-- Run in Supabase -> SQL Editor -> New query -> Run.
-- Uses the SAME Supabase project as psg-planner (production planning) so the whole
-- ERP shares one database. Table names are prefixed crm_ so nothing collides with
-- psg-planner's users/orders/wc_progress/ncr/holidays/capacity tables.

create table if not exists crm_clients (
  id text primary key,
  company text,
  contact text,
  designation text,
  phone text,
  email text,
  city text,
  industry text,
  lead_source text,
  priority text,
  assigned_to text,
  first_contact date,
  last_contact date,
  status text,
  notes text,
  revenue_potential numeric default 0,
  record_type text default 'Client',
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists crm_calls (
  id text primary key,
  call_date date,
  rep text,
  client_id text references crm_clients(id) on delete cascade,
  company text,
  contact text,
  duration numeric default 0,
  result text,
  interest numeric default 0,
  next_action text,
  follow_up date,
  notes text,
  converted text,
  created_at timestamptz default now()
);

create table if not exists crm_meetings (
  id text primary key,
  meet_date date,
  meet_time text,
  rep text,
  client_id text references crm_clients(id) on delete cascade,
  company text,
  contact text,
  type text,
  location text,
  agenda text,
  status text,
  follow_notes text,
  source_call text,
  created_at timestamptz default now()
);

create table if not exists crm_deals (
  id text primary key,
  close_date date,
  rep text,
  client_id text references crm_clients(id) on delete cascade,
  company text,
  product text,
  qty numeric default 0,
  unit_price numeric default 0,
  deal_value numeric default 0,
  collect_status text,
  collected numeric default 0,
  comm_rate numeric default 0,
  comm_earned numeric default 0,
  remarks text,
  created_at timestamptz default now()
);

create table if not exists crm_users (
  username text primary key,
  password text,
  role text,
  rep_name text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists crm_rep_targets (
  rep text primary key,
  target numeric default 0,
  comm_rate numeric default 0
);

create index if not exists idx_crm_calls_client on crm_calls(client_id);
create index if not exists idx_crm_meetings_client on crm_meetings(client_id);
create index if not exists idx_crm_deals_client on crm_deals(client_id);
create index if not exists idx_crm_clients_phone on crm_clients(phone);

-- Same permissive "demo" policy style as psg-planner — anon key can read/write,
-- fine for an internal tool. See README.md's security note before exposing this
-- outside the company network.
alter table crm_clients enable row level security;
drop policy if exists "demo" on crm_clients;
create policy "demo" on crm_clients for all using (true) with check (true);

alter table crm_calls enable row level security;
drop policy if exists "demo" on crm_calls;
create policy "demo" on crm_calls for all using (true) with check (true);

alter table crm_meetings enable row level security;
drop policy if exists "demo" on crm_meetings;
create policy "demo" on crm_meetings for all using (true) with check (true);

alter table crm_deals enable row level security;
drop policy if exists "demo" on crm_deals;
create policy "demo" on crm_deals for all using (true) with check (true);

alter table crm_users enable row level security;
drop policy if exists "demo" on crm_users;
create policy "demo" on crm_users for all using (true) with check (true);

alter table crm_rep_targets enable row level security;
drop policy if exists "demo" on crm_rep_targets;
create policy "demo" on crm_rep_targets for all using (true) with check (true);
