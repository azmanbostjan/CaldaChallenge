CREATE TYPE order_status AS ENUM ('Basket','Ordered','Paid','Shipped','Received');

CREATE TABLE dbo.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    shipping_address TEXT NOT NULL,
    recipient_name TEXT NOT NULL,
    status order_status NOT NULL DEFAULT 'Basket',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_orders_status ON orders(status);