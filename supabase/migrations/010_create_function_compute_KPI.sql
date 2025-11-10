CREATE OR REPLACE FUNCTION public.compute_kpis(
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
AS $func$
DECLARE
    v_start_date TIMESTAMP;
    v_end_date TIMESTAMP;
BEGIN
    v_start_date := COALESCE(p_start_date, (SELECT MIN(created_at) FROM public.stg_orders));
    v_end_date := COALESCE(p_end_date, NOW());

    RETURN QUERY
    WITH filtered_orders AS (
        SELECT *
        FROM public.stg_orders so
        WHERE so.created_at BETWEEN v_start_date AND v_end_date
          AND (p_user_ids IS NULL OR so.user_id = ANY(p_user_ids))
    ),
    user_orders AS (
        SELECT 
            fo.id AS order_id,
            fo.user_id AS uo_user_id,
            u.email AS uo_user_email,
            fo.order_total AS uo_order_total
        FROM filtered_orders fo
        JOIN public.users u ON fo.user_id = u.id
    ),
    user_order_items AS (
        SELECT
            uo.uo_user_id AS uoi_user_id,
            oi.item_id AS uoi_item_id,
            SUM(oi.quantity) AS total_quantity,
            SUM(oi.quantity * oi.price) AS total_revenue_item
        FROM public.stg_order_items oi
        JOIN user_orders uo ON oi.order_id = uo.order_id
        GROUP BY uo.uo_user_id, oi.item_id
    ),
    most_ordered_per_user AS (
        SELECT DISTINCT ON (uoi_user_id)
            uoi_user_id,
            uoi_item_id AS most_ordered_item
        FROM user_order_items
        ORDER BY uoi_user_id, total_quantity DESC
    ),
    total_revenue_per_user AS (
        SELECT 
            uo_user_id AS tru_user_id,
            uo_user_email AS tru_user_email,
            SUM(uo_order_total) AS tru_total_revenue,
            COUNT(*) AS tru_total_orders,
            AVG(uo_order_total) AS tru_avg_order_value
        FROM user_orders
        GROUP BY uo_user_id, uo_user_email
    ),
    highest_value_user AS (
        SELECT tru_user_id
        FROM total_revenue_per_user
        ORDER BY tru_total_revenue DESC
        LIMIT 1
    ),
    best_selling_item_cte AS (
        SELECT oi.item_id
        FROM public.stg_order_items oi
        JOIN user_orders uo ON oi.order_id = uo.order_id
        GROUP BY oi.item_id
        ORDER BY SUM(oi.quantity) DESC
        LIMIT 1
    ),
    highest_revenue_item_cte AS (
        SELECT oi.item_id
        FROM public.stg_order_items oi
        JOIN user_orders uo ON oi.order_id = uo.order_id
        GROUP BY oi.item_id
        ORDER BY SUM(oi.quantity * oi.price) DESC
        LIMIT 1
    )
    SELECT
        'user' AS kpi_type,
        tru.tru_user_id AS user_id,
        tru.tru_user_email AS user_email,
        tru.tru_total_orders AS total_orders,
        tru.tru_total_revenue AS total_revenue,
        tru.tru_avg_order_value AS avg_order_value,
        mop.most_ordered_item,
        CASE WHEN tru.tru_user_id = hv.tru_user_id THEN TRUE ELSE FALSE END AS highest_value_customer,
        bsi.item_id AS best_selling_item,
        hri.item_id AS highest_revenue_item
    FROM total_revenue_per_user tru
    LEFT JOIN most_ordered_per_user mop ON tru.tru_user_id = mop.uoi_user_id
    CROSS JOIN highest_value_user hv
    CROSS JOIN best_selling_item_cte bsi
    CROSS JOIN highest_revenue_item_cte hri

    UNION ALL

    SELECT
        'marketing' AS kpi_type,
        NULL AS user_id,
        NULL AS user_email,
        SUM(tru.tru_total_orders) AS total_orders,
        SUM(tru.tru_total_revenue) AS total_revenue,
        AVG(tru.tru_avg_order_value) AS avg_order_value,
        NULL AS most_ordered_item,
        TRUE AS highest_value_customer,
        bsi.item_id AS best_selling_item,
        hri.item_id AS highest_revenue_item
    FROM total_revenue_per_user tru
    CROSS JOIN best_selling_item_cte bsi
    CROSS JOIN highest_revenue_item_cte hri;

END;
$func$;
