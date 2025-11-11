-- Simulator for public.orders using user_id (uuid)
-- Creates a SECURITY DEFINER function to count rows visible to a simulated user UUID (as text).

CREATE OR REPLACE FUNCTION public.test_orders_rls_simulator_for_user(sim_user_uuid_text text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  cnt int;
  parsed_uuid uuid;
BEGIN
  -- Validate input is a UUID string
  BEGIN
    parsed_uuid := sim_user_uuid_text::uuid;
  EXCEPTION WHEN invalid_text_representation THEN
    RAISE EXCEPTION 'Provided sim_user_uuid_text is not a valid UUID: %', sim_user_uuid_text;
  END;

  -- Count rows that would be visible to that user according to typical RLS: user_id = auth.uid()
  SELECT COUNT(*) INTO cnt
  FROM public.orders
  WHERE user_id = parsed_uuid;

  IF cnt = 0 THEN
    RETURN 'RLS SUCCESS: no rows visible to ' || sim_user_uuid_text;
  ELSE
    RETURN 'RLS VIOLATION: ' || cnt || ' row(s) visible to ' || sim_user_uuid_text;
  END IF;
END;
$$;

-- Security: revoke execute from public so only privileged roles can run it.
REVOKE EXECUTE ON FUNCTION public.test_orders_rls_simulator_for_user(text) FROM PUBLIC;

-- Example test calls:
-- Replace the UUID below with the UUID of a non-owner user you expect to see zero rows.
SELECT public.test_orders_rls_simulator_for_user('10be9516-0b49-4e64-88fd-16df68c0cf58') AS result;

-- Example: test with a real user UUID (replace with actual user id)
-- SELECT public.test_orders_rls_simulator_for_user('11111111-2222-3333-4444-555555555555') AS result;