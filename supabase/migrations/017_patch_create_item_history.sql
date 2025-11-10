-- =============================================
-- Migration: patch item_history trigger to track all CRUD operations
-- =============================================

-- Drop old trigger if it exists
DROP TRIGGER IF EXISTS trg_items_catalog_history ON items_catalog;

-- Replace trigger function
CREATE OR REPLACE FUNCTION track_item_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO item_history(
            item_id,
            old_price,
            new_price,
            operation_type,
            changed_at,
            created_at,
            updated_at
        )
        VALUES (
            NEW.id,
            NULL,
            NEW.price,
            'INSERT',
            now(),
            NEW.created_at,
            NEW.updated_at
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO item_history(
            item_id,
            old_price,
            new_price,
            operation_type,
            changed_at,
            created_at,
            updated_at
        )
        VALUES (
            NEW.id,
            OLD.price,
            NEW.price,
            'UPDATE',
            now(),
            NEW.created_at,
            NEW.updated_at
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO item_history(
            item_id,
            old_price,
            new_price,
            operation_type,
            changed_at,
            created_at,
            updated_at
        )
        VALUES (
            OLD.id,
            OLD.price,
            NULL,
            'DELETE',
            now(),
            OLD.created_at,
            OLD.updated_at
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- Re-attach trigger to items_catalog
CREATE TRIGGER trg_items_catalog_history
AFTER INSERT OR UPDATE OR DELETE ON items_catalog
FOR EACH ROW
EXECUTE FUNCTION track_item_changes();
