ALTER TABLE public.item_history
ADD COLUMN IF NOT EXISTS operation_type TEXT NOT NULL DEFAULT 'update';
