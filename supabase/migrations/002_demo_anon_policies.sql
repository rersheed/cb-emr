-- TEMPORARY demo bootstrap policies — anon open R/W.
-- Replace with role-scoped policies before any production use.
-- Documented as temporary for CB-EMR web demo.

alter table public.states enable row level security;
alter table public.lgas enable row level security;
alter table public.wards enable row level security;
alter table public.polling_units enable row level security;
alter table public.profiles enable row level security;
alter table public.elections enable row level security;
alter table public.parties enable row level security;
alter table public.polling_results enable row level security;
alter table public.result_details enable row level security;
alter table public.opening_reports enable row level security;
alter table public.incidents enable row level security;
alter table public.approvals enable row level security;
alter table public.audit_log enable row level security;

create policy "anon_all_demo" on public.states for all using (true) with check (true);
create policy "anon_all_demo" on public.lgas for all using (true) with check (true);
create policy "anon_all_demo" on public.wards for all using (true) with check (true);
create policy "anon_all_demo" on public.polling_units for all using (true) with check (true);
create policy "anon_all_demo" on public.profiles for all using (true) with check (true);
create policy "anon_all_demo" on public.elections for all using (true) with check (true);
create policy "anon_all_demo" on public.parties for all using (true) with check (true);
create policy "anon_all_demo" on public.polling_results for all using (true) with check (true);
create policy "anon_all_demo" on public.result_details for all using (true) with check (true);
create policy "anon_all_demo" on public.opening_reports for all using (true) with check (true);
create policy "anon_all_demo" on public.incidents for all using (true) with check (true);
create policy "anon_all_demo" on public.approvals for all using (true) with check (true);
create policy "anon_all_demo" on public.audit_log for all using (true) with check (true);

grant select, insert, update, delete on all tables in schema public to anon, authenticated;
