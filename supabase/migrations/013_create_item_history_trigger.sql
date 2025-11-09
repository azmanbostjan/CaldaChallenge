-- ========================================
-- Consolidated trigger for dbo.items_catalog history
-- Handles INSERT, UPDATE, DELETE
-- ========================================

CREATE OR REPLACE FUNCTION dbo.log_items_catalog_changes()
RETURNS TRIGGER AS $$
DECLARE
    action_type TEXT;
BEGIN
    -- Determine the operation type
    IF TG_OP = 'INSERT' THEN
        action_type := 'INSERT';
        INSERT INTO dbo.item_history(
            item_id, name, description, price, stock, status, changed_at, change_type
        )
        VALUES (
            NEW.id, NEW.name, NEW.description, NEW.price, NEW.stock, NEW.status, now(), action_type
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        action_type := 'UPDATE';
        INSERT INTO dbo.item_history(
            item_id, name, description, price, stock, status, changed_at, change_type
        )
        VALUES (
            OLD.id, OLD.name, OLD.description, OLD.price, OLD.stock, OLD.status, now(), action_type
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        action_type := 'DELETE';
        INSERT INTO dbo.item_history(
            item_id, name, description, price, stock, status, changed_at, change_type
        )
        VALUES (
            OLD.id, OLD.name, OLD.description, OLD.price, OLD.stock, OLD.status, now(), action_type
        );
        RETURN OLD;

    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create a single trigger for all operations
CREATE TRIGGER trg_items_catalog_history
AFTER INSERT OR UPDATE OR DELETE ON dbo.items_catalog
FOR EACH ROW
EXECUTE FUNCTION dbo.log_items_catalog_changes();
