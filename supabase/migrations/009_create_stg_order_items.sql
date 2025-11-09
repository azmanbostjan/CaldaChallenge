-- =============================================
-- Table: stg_order_items
-- =============================================
CREATE TABLE IF NOT EXISTS stg.stg_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES stg.stg_orders(id),
    item_id UUID NOT NULL REFERENCES public.items_catalog(id),
    quantity INT NOT NULL,
    price NUMERIC NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- Enable row-level security
ALTER TABLE stg.stg_order_items ENABLE ROW LEVEL SECURITY;

-- =============================================
-- Append-only policies
-- =============================================

-- Only allow INSERTs
DROP POLICY IF EXISTS "Append-only insert" ON stg.stg_order_items;
CREATE POLICY "Append-only insert" ON stg.stg_order_items
FOR INSERT
WITH CHECK (true);

-- Prevent UPDATEs
DROP POLICY IF EXISTS "No updates on stg_order_items" ON stg.stg_order_items;
CREATE POLICY "No updates on stg_order_items" ON stg.stg_order_items
FOR UPDATE
USING (false)
WITH CHECK (false);

-- Prevent DELETEs
DROP POLICY IF EXISTS "No deletes on stg_order_items" ON stg.stg_order_items;
CREATE POLICY "No deletes on stg_order_items" ON stg.stg_order_items
FOR DELETE
USING (false);

-- =============================================
-- Indexes
-- =============================================
CREATE INDEX IF NOT EXISTS idx_stg_order_items_order_id ON stg.stg_order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_stg_order_items_item_id ON stg.stg_order_items(item_id);
