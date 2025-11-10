-- tests/test_archive_orders.sql
BEGIN;

SET LOCAL ROLE 'admin';

-- Step 1: Create a test order older than 7 days
WITH new_order AS (
    INSERT INTO public.orders (user_id, shipping_address, recipient_name, status, created_at)
    VALUES (
        (SELECT id FROM public.users LIMIT 1),
        '123 Test St',
        'Test User',
        'completed',
        NOW() - INTERVAL '10 days'
    )
    RETURNING id
)
INSERT INTO public.order_items (order_id, item_id, quantity, price)
SELECT no.id, ic.id, 1, ic.price
FROM new_order no
CROSS JOIN public.items_catalog ic
LIMIT 1;

-- Step 2: Invoke the archive function
SELECT archive_old_orders(); -- assuming the RPC function exists

-- Step 3: Verify the order moved to staging
WITH staged_order AS (
    SELECT * FROM public.stg_orders
    WHERE created_at < NOW() - INTERVAL '7 days'
)
SELECT
    CASE
        WHEN COUNT(*) >= 1 THEN RAISE NOTICE 'Orders archived to stg_orders OK'
        ELSE RAISE EXCEPTION 'No orders found in stg_orders!'
    END
FROM staged_order;

-- Step 4: Verify the order items moved to staging
WITH staged_items AS (
    SELECT * FROM public.stg_order_items
    WHERE order_id IN (SELECT id FROM public.stg_orders)
)
SELECT
    CASE
        WHEN COUNT(*) >= 1 THEN RAISE NOTICE 'Order items archived to stg_order_items OK'
        ELSE RAISE EXCEPTION 'No order items found in stg_order_items!'
    END
FROM staged_items;

-- Step 5: Verify the original public.orders no longer contains the archived order
WITH remaining_orders AS (
    SELECT * FROM public.orders
    WHERE created_at < NOW() - INTERVAL '7 days'
)
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN RAISE NOTICE 'Original orders table cleared OK'
        ELSE RAISE EXCEPTION 'Archived orders still exist in public.orders!'
    END
FROM remaining_orders;

ROLLBACK;
