-- Migration: 002_schedule_archive_old_orders.sql
-- Description: Create helper function and schedule cron for testing

-- 1. Helper function to call Edge Function (placeholder key/project)
create or replace function public.trigger_archive_old_orders()
returns void language plpgsql as $$
declare
begin
    perform
        (select content
         from http_post(
           'https://qvcpiwcxgzxnseyglwcm.functions.supabase.co/archive_old_orders', 
           '{}'::jsonb,
           hstore(array['Authorization'], array['Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2Y3Bpd2N4Z3p4bnNleWdsd2NtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Mjc5NzUxNSwiZXhwIjoyMDc4MzczNTE1fQ.7kfSwhD95tO_6dx3-3VvSvNdmkRyKdFN79KYCd1VPqw'])  -- replace with service role key
         ));
end;
$$;

-- 2. Schedule the cron (daily at 03:00 UTC for testing)
select cron.schedule(
  'archive_old_orders_cron',          -- unique job name
  '0 3 * * *',                        -- cron expression (UTC)
  'select public.trigger_archive_old_orders()'
);

-- Optional rollback
-- select cron.unschedule('archive_old_orders_cron');
-- drop function if exists public.trigger_archive_old_orders();
