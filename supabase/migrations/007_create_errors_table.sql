CREATE TABLE public.function_errors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    function_name TEXT NOT NULL,
    error_message TEXT NOT NULL,
    payload JSONB NULL, -- optional, stores the input or context
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
