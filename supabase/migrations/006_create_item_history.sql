-- =============================================
-- Table: item_history
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

-- =============================================
-- Trigger function: track_item_changes (fixed search_path)
-- Inserts a record into item_history whenever an item changes
-- =============================================
CREATE OR REPLACE FUNCTION dbo.track_item_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO dbo.item_history(
        item_id,
        old_price,
        new_price
    )
    VALUES (
        OLD.id,
        OLD.price,
        NEW.price
    );
    RETURN NEW;
END;
$$;
