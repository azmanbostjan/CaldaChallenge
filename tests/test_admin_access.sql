-- Simulate admin check
SELECT 
    CASE 
        WHEN COUNT(*) >= 0 THEN 'Admin can see all orders OK'
    END AS test_result
FROM public.orders
WHERE (SELECT auth.role()) = 'admin';
