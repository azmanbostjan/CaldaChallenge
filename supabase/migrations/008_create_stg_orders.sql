-- =============================================
-- Table: stg_orders
-- =============================================
CREATE TABLE IF NOT EXISTS stg.stg_orders (
    id UUID PRIMARY KEY, -- original order ID
    user_id UUID NOT NULL REFERENCES dbo.users(id),
    shipping_address TEXT NOT NULL,
    recipient_name TEXT NOT NULL,
    status dbo.order_status NOT NULL,
    order_total NUMERIC NOT NULL,      -- total of individual order
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    archived_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Enable row-level security
ALTER TABLE stg.stg_orders ENABLE ROW LEVEL SECURITY;

-- =============================================
-- Append-only policies
-- =============================================

-- Only allow INSERTs
DROP POLICY IF EXISTS "Append-only insert" ON stg.stg_orders;
CREATE POLICY "Append-only insert" ON stg.stg_orders
FOR INSERT
WITH CHECK (true);

-- Prevent UPDATEs
DROP POLICY IF EXISTS "No updates" ON stg.stg_orders;
CREATE POLICY "No updates" ON stg.stg_orders
FOR UPDATE
USING (false);

-- Prevent DELETEs
DROP POLICY IF EXISTS "No deletes" ON stg.stg_orders;
CREATE POLICY "No deletes" ON stg.stg_orders
FOR DELETE
USING (false);

-- =============================================
-- Indexes
-- =============================================
CREATE INDEX IF NOT EXISTS idx_stg_orders_user_id ON stg.stg_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_stg_orders_archived_at ON stg.stg_orders(archived_at);
