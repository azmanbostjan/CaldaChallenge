-- Function to automatically update updated_at column
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for each table
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_items_updated_at
BEFORE UPDATE ON items_catalog
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_order_items_updated_at
BEFORE UPDATE ON order_items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_item_history_updated_at
BEFORE UPDATE ON item_history
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
