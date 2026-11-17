-- Enable Realtime for Situation Room (ElecMonitor) subscriptions.
-- Apply in Supabase SQL editor if tables are not already in the publication.

alter publication supabase_realtime add table public.polling_results;
alter publication supabase_realtime add table public.incidents;
alter publication supabase_realtime add table public.opening_reports;
alter publication supabase_realtime add table public.approvals;
alter publication supabase_realtime add table public.profiles;
alter publication supabase_realtime add table public.result_details;

-- Note: if a table is already in the publication, the statement errors — skip that line.
