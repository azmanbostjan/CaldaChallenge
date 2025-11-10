-- Enum type in public schema
CREATE TYPE public.order_status AS ENUM ('Basket','Ordered','Paid','Shipped','Received');

-- Orders table in public schema
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    shipping_address TEXT NOT NULL,
    recipient_name TEXT NOT NULL,
    status public.order_status NOT NULL DEFAULT 'Basket',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Index with schema-qualified table
CREATE INDEX idx_orders_status ON public.orders(status);
