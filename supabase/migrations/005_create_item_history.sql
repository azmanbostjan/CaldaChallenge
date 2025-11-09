CREATE TABLE dbo.item_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID REFERENCES dbo.items_catalog(id),
    old_price NUMERIC,
    new_price NUMERIC,
    changed_at TIMESTAMP NOT NULL DEFAULT now(),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Trigger function to track item changes
CREATE OR REPLACE FUNCTION dbo.track_item_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dbo.item_history(item_id, old_price, new_price)
    VALUES (OLD.id, OLD.price, NEW.price);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
