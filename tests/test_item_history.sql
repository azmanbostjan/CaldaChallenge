BEGIN;

-- Example: Reduce stock of item1
UPDATE public.items_catalog
SET stock = stock - 1
WHERE id = (SELECT id FROM public.items_catalog LIMIT 1)
RETURNING id, stock;

-- Check that item_history recorded the change
WITH hist AS (
    SELECT *
    FROM public.item_history
    WHERE item_id = (SELECT id FROM public.items_catalog LIMIT 1)
    ORDER BY changed_at DESC
    LIMIT 1
)
SELECT
    COUNT(*) AS hist_count,
    CASE
        WHEN COUNT(*) = 1 THEN 'item_history triggered correctly for stock change'
        ELSE 'item_history not updated!'
    END AS message
FROM hist;

ROLLBACK;
