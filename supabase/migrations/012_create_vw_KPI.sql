CREATE OR REPLACE VIEW vw.vw_KPI AS
SELECT *
FROM dbo.compute_kpis(
    (NOW() - INTERVAL '30 days')::timestamp,  -- start_date (cast to TIMESTAMP)
    NOW()::timestamp                           -- end_date (cast to TIMESTAMP)
);
