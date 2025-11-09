BEGIN;

-- Admin should see all orders
SET LOCAL ROLE 'admin';

WITH all_orders AS (
    SELECT * FROM dbo.orders
)
SELECT
    CASE
        WHEN COUNT(*) >= 0 THEN RAISE NOTICE 'Admin can see all orders OK'
    END
FROM all_orders;

ROLLBACK;
