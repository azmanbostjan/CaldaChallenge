BEGIN;

SET LOCAL ROLE 'user';

-- Example: Reduce stock of item1
UPDATE public.items_catalog
SET stock = stock - 1
WHERE id = (SELECT id FROM public.items_catalog LIMIT 1);

-- Check that item_history recorded the change
WITH hist AS (
    SELECT * FROM public.item_history
    WHERE item_id = (SELECT id FROM public.items_catalog LIMIT 1)
    ORDER BY changed_at DESC
    LIMIT 1
)
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN RAISE NOTICE 'item_history triggered correctly for stock change'
        ELSE RAISE EXCEPTION 'item_history not updated!'
    END
FROM hist;

ROLLBACK;
