CREATE TYPE item_status AS ENUM ('Available','Out of stock','Discontinued');

CREATE TABLE public.items_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL CHECK (stock >= 0),
    status item_status NOT NULL DEFAULT 'Available',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_items_catalog_status ON items_catalog(status);