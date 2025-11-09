-- Enum type stays the same (can also be schema-qualified if you want)
CREATE TYPE dbo.item_status AS ENUM ('Available','Out of stock','Discontinued');

-- Table with dbo schema
CREATE TABLE dbo.items_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL CHECK (stock >= 0),
    status dbo.item_status NOT NULL DEFAULT 'Available',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Index with schema-qualified table
CREATE INDEX idx_items_catalog_status ON dbo.items_catalog(status);
