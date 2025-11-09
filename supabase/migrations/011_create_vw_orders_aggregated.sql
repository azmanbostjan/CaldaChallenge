CREATE OR REPLACE VIEW vw.orders_aggregated AS
SELECT
    o.id AS order_id,
    o.user_id,
    o.shipping_address,
    o.recipient_name,
    o.status AS order_status,
    o.created_at AS order_created_at,
    o.updated_at AS order_updated_at,
    -- Aggregate order items as a JSON array
    COALESCE(
        json_agg(
            json_build_object(
                'item_id', oi.item_id,
                'name', ci.name,
                'quantity', oi.quantity,
                'price', oi.price,
                'status', ci.status
            )
        ) FILTER (WHERE oi.id IS NOT NULL),
        '[]'
    ) AS order_items
FROM dbo.orders o
LEFT JOIN dbo.order_items oi ON oi.order_id = o.id
LEFT JOIN public.items_catalog ci ON ci.id = oi.item_id
GROUP BY o.id;
