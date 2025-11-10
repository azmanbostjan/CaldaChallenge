-- =============================================
-- Function: set_updated_at (fixed search_path)
-- Automatically updates updated_at column on UPDATE
-- =============================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

-- =============================================
-- Triggers for each table (schema-qualified)
-- =============================================

-- Users table
DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Items catalog table (public schema)
DROP TRIGGER IF EXISTS trg_items_updated_at ON public.items_catalog;
CREATE TRIGGER trg_items_updated_at
BEFORE UPDATE ON public.items_catalog
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Orders table
DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Order items table
DROP TRIGGER IF EXISTS trg_order_items_updated_at ON public.order_items;
CREATE TRIGGER trg_order_items_updated_at
BEFORE UPDATE ON public.order_items
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Item history table
DROP TRIGGER IF EXISTS trg_item_history_updated_at ON public.item_history;
CREATE TRIGGER trg_item_history_updated_at
BEFORE UPDATE ON public.item_history
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
