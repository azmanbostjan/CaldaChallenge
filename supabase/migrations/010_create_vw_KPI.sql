CREATE OR REPLACE VIEW vw.vw_KPI AS
SELECT *
FROM compute_kpis(
    NOW() - INTERVAL '30 days',  -- start_date
    NOW()                         -- end_date
);