CREATE TABLE stg.stg_orders (
    id UUID PRIMARY KEY, -- original order ID
    user_id UUID NOT NULL REFERENCES users(id),
    shipping_address TEXT NOT NULL,
    recipient_name TEXT NOT NULL,
    status order_status NOT NULL,
    order_total NUMERIC NOT NULL,      -- total of individual order
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    archived_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Make the table append-only: no updates or deletes allowed
ALTER TABLE stg_orders
    ENABLE ROW LEVEL SECURITY;

-- Only allow INSERTs
CREATE POLICY "Append-only insert" ON stg_orders
FOR INSERT
USING (true);

CREATE POLICY "No updates or deletes" ON stg_orders
FOR UPDATE, DELETE
USING (false)
WITH CHECK (false);

CREATE INDEX idx_stg_orders_user_id ON stg_orders(user_id);
CREATE INDEX idx_stg_orders_archived_at ON stg_orders(archived_at);