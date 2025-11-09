CREATE TABLE dbo.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES dbo.orders(id) ON DELETE CASCADE,
    item_id UUID REFERENCES dbo.items_catalog(id),
    item_name_snapshot TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price NUMERIC NOT NULL CHECK (price >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_order_items_order_id ON dbo.order_items(order_id);
CREATE INDEX idx_order_items_item_id ON dbo.order_items(item_id);
