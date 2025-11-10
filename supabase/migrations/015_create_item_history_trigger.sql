-- =============================================
-- Trigger function: log_items_catalog_changes (fixed search_path)
-- Handles INSERT, UPDATE, DELETE on public.items_catalog
-- =============================================
CREATE OR REPLACE FUNCTION public.log_items_catalog_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
    action_type TEXT;
BEGIN
    -- Determine the operation type
    IF TG_OP = 'INSERT' THEN
        action_type := 'INSERT';
        INSERT INTO public.item_history(
            item_id, name, description, price, stock, status, changed_at, change_type
        )
        VALUES (
            NEW.id, NEW.name, NEW.description, NEW.price, NEW.stock, NEW.status, now(), action_type
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        action_type := 'UPDATE';
        INSERT INTO public.item_history(
            item_id, name, description, price, stock, status, changed_at, change_type
        )
        VALUES (
            OLD.id, OLD.name, OLD.description, OLD.price, OLD.stock, OLD.status, now(), action_type
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        action_type := 'DELETE';
        INSERT INTO public.item_history(
            item_id, name, description, price, stock, status, changed_at, change_type
        )
        VALUES (
            OLD.id, OLD.name, OLD.description, OLD.price, OLD.stock, OLD.status, now(), action_type
        );
        RETURN OLD;

    END IF;
END;
$$;

-- =============================================
-- Trigger for items_catalog table
-- =============================================
DROP TRIGGER IF EXISTS trg_items_catalog_history ON public.items_catalog;

CREATE TRIGGER trg_items_catalog_history
AFTER INSERT OR UPDATE OR DELETE ON public.items_catalog
FOR EACH ROW
EXECUTE FUNCTION public.log_items_catalog_changes();
