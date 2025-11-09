CREATE TABLE stg.stg_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES stg_orders(id),
    item_id UUID NOT NULL REFERENCES catalog_items(id),
    quantity INT NOT NULL,
    price NUMERIC NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

ALTER TABLE stg_order_items
    ENABLE ROW LEVEL SECURITY;

-- Only allow INSERTs
CREATE POLICY "Append-only insert" ON stg_order_items
FOR INSERT
USING (true);

CREATE POLICY "No updates or deletes" ON stg_order_items
FOR UPDATE, DELETE
USING (false)
WITH CHECK (false);

CREATE INDEX idx_stg_order_items_order_id ON stg_order_items(order_id);
CREATE INDEX idx_stg_order_items_item_id ON stg_order_items(item_id);
