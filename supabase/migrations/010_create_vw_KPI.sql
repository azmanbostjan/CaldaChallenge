CREATE OR REPLACE VIEW dbo.vw_KPI AS
SELECT *
FROM dbo.compute_kpis(
    NOW() - INTERVAL '30 days',  -- start_date
    NOW()                         -- end_date
);
