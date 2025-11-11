-- Ensure pg_cron extension is installed
create extension if not exists pg_cron;

-- Schedule job
select cron.schedule(
    'archive_old_orders_cron',  -- unique job name
    '*/15 * * * *',             -- every 15 minutes
    'select public.archive_old_orders()'
);
