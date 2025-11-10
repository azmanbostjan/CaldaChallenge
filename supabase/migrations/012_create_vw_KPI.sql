CREATE OR REPLACE VIEW public.vw_KPI AS
SELECT *
FROM public.compute_kpis(
    (NOW() - INTERVAL '30 days')::timestamp,  -- start_date (cast to TIMESTAMP)
    NOW()::timestamp                           -- end_date (cast to TIMESTAMP)
);
