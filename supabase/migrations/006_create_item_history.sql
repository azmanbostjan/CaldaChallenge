-- =============================================
-- Trigger function: track_item_changes
-- Tracks all CRUD operations on items_catalog
-- Only stores old/new price and operation type
-- =============================================

CREATE TABLE dbo.item_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID REFERENCES public.items_catalog(id),
    old_price NUMERIC,
    new_price NUMERIC,
    changed_at TIMESTAMP NOT NULL DEFAULT now(),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE OR REPLACE FUNCTION public.track_item_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.item_history(
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
        INSERT INTO public.item_history(
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
        INSERT INTO public.item_history(
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

    RETURN NULL; -- fallback
END;
$$;

-- =============================================
-- Attach trigger to items_catalog
-- =============================================
DROP TRIGGER IF EXISTS trg_items_catalog_history ON public.items_catalog;

CREATE TRIGGER trg_items_catalog_history
AFTER INSERT OR UPDATE OR DELETE ON public.items_catalog
FOR EACH ROW
EXECUTE FUNCTION public.track_item_changes();
