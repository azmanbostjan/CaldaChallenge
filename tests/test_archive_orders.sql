-- tests/test_archive_orders.sql
BEGIN;

-- Step 1: Create a test order older than 7 days
WITH new_order AS (
    INSERT INTO public.orders (user_id, shipping_address, recipient_name, status, created_at)
    VALUES (
        (SELECT id FROM public.users LIMIT 1),
        '123 Test St',
        'Test User',
        'Basket',  -- valid enum value
        NOW() - INTERVAL '10 days'
    )
    RETURNING id
)
INSERT INTO public.order_items (order_id, item_id, item_name_snapshot, quantity, price)
SELECT 
    no.id, 
    ic.id, 
    'Test Item Snapshot',  -- provide a non-null snapshot
    1, 
    ic.price
FROM new_order no
CROSS JOIN public.items_catalog ic
LIMIT 1;

-- Step 2: Invoke the archive function
SELECT archive_old_orders() AS archived_total_value;

-- Step 3: Verify the order moved to staging
SELECT COUNT(*) AS staged_orders_count,
       CASE WHEN COUNT(*) >= 1 THEN 'Orders archived to stg_orders OK'
            ELSE 'No orders found in stg_orders!' END AS message
FROM public.stg_orders
WHERE created_at < NOW() - INTERVAL '7 days';

-- Step 4: Verify the order items moved to staging
SELECT COUNT(*) AS staged_items_count,
       CASE WHEN COUNT(*) >= 1 THEN 'Order items archived to stg_order_items OK'
            ELSE 'No order items found in stg_order_items!' END AS message
FROM public.stg_order_items
WHERE order_id IN (SELECT id FROM public.stg_orders);

-- Step 5: Verify the original public.orders no longer contains the archived order
SELECT COUNT(*) AS remaining_orders_count,
       CASE WHEN COUNT(*) = 0 THEN 'Original orders table cleared OK'
            ELSE 'Archived orders still exist in public.orders!' END AS message
FROM public.orders
WHERE created_at < NOW() - INTERVAL '7 days';

ROLLBACK;
