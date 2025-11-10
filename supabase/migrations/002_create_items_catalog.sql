-- Enum type stays in public (schema-qualified)
CREATE TYPE public.item_status AS ENUM ('Available','Out of stock','Discontinued');

-- Table in public schema
CREATE TABLE public.items_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL CHECK (stock >= 0),
    status public.item_status NOT NULL DEFAULT 'Available',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Index on public.items_catalog
CREATE INDEX idx_items_catalog_status ON public.items_catalog(status);
