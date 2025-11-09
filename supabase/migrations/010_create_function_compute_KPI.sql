-- =============================================
-- Function: compute_kpis (fixed search_path)
-- Computes per-user and marketing KPIs for orders
-- Optional filters: start_date, end_date, user_ids
-- =============================================
CREATE OR REPLACE FUNCTION dbo.compute_kpis(
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    p_user_ids UUID[] DEFAULT NULL
)
RETURNS TABLE (
    kpi_type TEXT,
    user_id UUID,
    user_email TEXT,
    total_orders INT,
    total_revenue NUMERIC,
    avg_order_value NUMERIC,
    most_ordered_item UUID,
    highest_value_customer BOOLEAN,
    best_selling_item UUID,
    highest_revenue_item UUID
)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
BEGIN
    start_date := COALESCE(p_start_date, (SELECT MIN(created_at) FROM stg.stg_orders));
    end_date := COALESCE(p_end_date, NOW());

    WITH filtered_orders AS (
        SELECT *
        FROM stg.stg_orders
        WHERE created_at BETWEEN start_date AND end_date
          AND (p_user_ids IS NULL OR user_id = ANY(p_user_ids))
    ),
    user_orders AS (
        SELECT 
            o.id AS order_id,
            o.user_id,
            u.email AS user_email,
            o.order_total
        FROM filtered_orders o
        JOIN dbo.users u ON o.user_id = u.id
    ),
    user_order_items AS (
        SELECT
            uo.user_id,
            oi.item_id,
            SUM(oi.quantity) AS total_quantity,
            SUM(oi.quantity * oi.price) AS total_revenue_item
        FROM stg.stg_order_items oi
        JOIN user_orders uo ON oi.order_id = uo.order_id
        GROUP BY uo.user_id, oi.item_id
    ),
    most_ordered_per_user AS (
        SELECT DISTINCT ON (user_id)
            user_id,
            item_id AS most_ordered_item
        FROM user_order_items
        ORDER BY user_id, total_quantity DESC
    ),
    total_revenue_per_user AS (
        SELECT 
            user_id,
            SUM(order_total) AS total_revenue,
            COUNT(*) AS total_orders,
            AVG(order_total) AS avg_order_value
        FROM user_orders
        GROUP BY user_id
    ),
    highest_value_user AS (
        SELECT user_id
        FROM total_revenue_per_user
        ORDER BY total_revenue DESC
        LIMIT 1
    ),
    best_selling_item_cte AS (
        SELECT item_id
        FROM stg.stg_order_items oi
        JOIN user_orders uo ON oi.order_id = uo.order_id
        GROUP BY item_id
        ORDER BY SUM(quantity) DESC
        LIMIT 1
    ),
    highest_revenue_item_cte AS (
        SELECT item_id
        FROM stg.stg_order_items oi
        JOIN user_orders uo ON oi.order_id = uo.order_id
        GROUP BY item_id
        ORDER BY SUM(quantity * price) DESC
        LIMIT 1
    )
    SELECT
        'user' AS kpi_type,
        tru.user_id,
        tru.user_email,
        tru.total_orders,
        tru.total_revenue,
        tru.avg_order_value,
        mop.most_ordered_item,
        CASE WHEN tru.user_id = hv.user_id THEN TRUE ELSE FALSE END AS highest_value_customer,
        bsi.item_id AS best_selling_item,
        hri.item_id AS highest_revenue_item
    FROM total_revenue_per_user tru
    LEFT JOIN most_ordered_per_user mop ON tru.user_id = mop.user_id
    CROSS JOIN highest_value_user hv
    CROSS JOIN best_selling_item_cte bsi
    CROSS JOIN highest_revenue_item_cte hri

    UNION ALL

    SELECT
        'marketing' AS kpi_type,
        NULL AS user_id,
        NULL AS user_email,
        SUM(tru.total_orders) AS total_orders,
        SUM(tru.total_revenue) AS total_revenue,
        AVG(tru.avg_order_value) AS avg_order_value,
        NULL AS most_ordered_item,
        TRUE AS highest_value_customer,
        bsi.item_id AS best_selling_item,
        hri.item_id AS highest_revenue_item
    FROM total_revenue_per_user tru
    CROSS JOIN best_selling_item_cte bsi
    CROSS JOIN highest_revenue_item_cte hri;
END;
$$;
