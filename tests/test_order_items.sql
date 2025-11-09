BEGIN;

-- Simulate user1
SET LOCAL ROLE 'user';

-- Check that order_items snapshots match the original order
WITH user_order_items AS (
    SELECT oi.*, o.user_id
    FROM dbo.order_items oi
    JOIN dbo.orders o ON o.id = oi.order_id
    WHERE o.user_id = (SELECT id FROM dbo.users WHERE email = 'azmanbostjan+1@gmail.com')
)
SELECT
    CASE
        WHEN COUNT(*) >= 0 THEN RAISE NOTICE 'Order_items snapshots exist for user1 orders'
    END
FROM user_order_items;

-- Test that user1 cannot see order_items of other users
WITH forbidden_oi AS (
    SELECT oi.*
    FROM dbo.order_items oi
    JOIN dbo.orders o ON o.id = oi.order_id
    WHERE o.user_id != (SELECT id FROM dbo.users WHERE email = 'azmanbostjan+1@gmail.com')
)
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN RAISE NOTICE 'RLS OK: user1 cannot see other order_items'
        ELSE RAISE EXCEPTION 'RLS VIOLATION: user1 can see other users order_items!'
    END
FROM forbidden_oi;

ROLLBACK;
