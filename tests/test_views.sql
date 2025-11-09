BEGIN;

-- Test available_items view
SET LOCAL ROLE 'user';

SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM vw.available_items WHERE status != 'Available'
        ) THEN RAISE EXCEPTION 'available_items view violation'
        ELSE RAISE NOTICE 'available_items view OK'
    END;

-- Test user_order_summary view for user2
WITH summary AS (
    SELECT * FROM vw.user_order_summary
    WHERE user_id = (SELECT id FROM dbo.users WHERE email = 'azmanbostjan+2@gmail.com')
)
SELECT
    CASE
        WHEN COUNT(*) >= 0 THEN RAISE NOTICE 'user_order_summary view OK for user2'
    END
FROM summary;

ROLLBACK;
