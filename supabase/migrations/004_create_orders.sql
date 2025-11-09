-- Enum type in dbo schema
CREATE TYPE dbo.order_status AS ENUM ('Basket','Ordered','Paid','Shipped','Received');

-- Orders table in dbo schema
CREATE TABLE dbo.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES dbo.users(id) ON DELETE CASCADE,
    shipping_address TEXT NOT NULL,
    recipient_name TEXT NOT NULL,
    status dbo.order_status NOT NULL DEFAULT 'Basket',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Index with schema-qualified table
CREATE INDEX idx_orders_status ON dbo.orders(status);
