-- Use the service_role connection
-- or explicitly run as the service_role in SQL editor
UPDATE public.items_catalog
SET stock = stock - 1
WHERE id = (SELECT id FROM public.items_catalog LIMIT 1);

-- Verify item_history
SELECT *
FROM public.item_history
WHERE item_id = (SELECT id FROM public.items_catalog LIMIT 1)
ORDER BY changed_at DESC
LIMIT 1;
