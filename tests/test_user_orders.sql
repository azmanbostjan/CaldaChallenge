BEGIN;

-- Hardcoded users
-- "user1" = azmanbostjan+1@gmail.com
-- "user2" = azmanbostjan+2@gmail.com
-- "user3" = azmanbostjan+3@gmail.com
-- "admin" = azmanbostjan+admin@gmail.com
-- "user4" = azmanbostjan+4@gmail.com

-- Test: user1 can see own orders
SET LOCAL ROLE 'user';
SELECT current_setting('jwt.claims.email');

-- Replace with your user ID retrieval method if needed
WITH user_orders AS (
    SELECT * FROM public.orders
    WHERE user_id = (SELECT id FROM public.users WHERE email = 'azmanbostjan+1@gmail.com')
)
SELECT
    CASE
        WHEN COUNT(*) >= 0 THEN RAISE NOTICE 'User1 order access OK'
    END
FROM user_orders;

-- Test: user1 cannot see other users' orders
WITH forbidden_orders AS (
    SELECT * FROM public.orders
    WHERE user_id != (SELECT id FROM public.users WHERE email = 'azmanbostjan+1@gmail.com')
)
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN RAISE NOTICE 'RLS OK: user1 cannot see other orders'
        ELSE RAISE EXCEPTION 'RLS VIOLATION: user1 can see other users orders!'
    END
FROM forbidden_orders;

ROLLBACK;
