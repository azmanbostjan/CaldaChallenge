-- ========================================
-- 1. users table
-- ========================================
ALTER TABLE dbo.users ENABLE ROW LEVEL SECURITY;

-- Users can view/update only their own account
CREATE POLICY "Users can view own account" ON dbo.users
FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own account" ON dbo.users
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Admins can do anything
CREATE POLICY "Admins full access to users" ON dbo.users
FOR ALL
USING (auth.role() = 'admin')
WITH CHECK (auth.role() = 'admin');

-- ========================================
-- 2. orders table
-- ========================================
ALTER TABLE dbo.orders ENABLE ROW LEVEL SECURITY;

-- Users can view their own orders
CREATE POLICY "Users can view own orders" ON dbo.orders
FOR SELECT
USING (user_id = auth.uid());

-- Users can insert orders for themselves
CREATE POLICY "Users can insert own orders" ON dbo.orders
FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Users can update only their own orders
CREATE POLICY "Users can update own orders" ON dbo.orders
FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Users can delete only their own orders
CREATE POLICY "Users can delete own orders" ON dbo.orders
FOR DELETE
USING (user_id = auth.uid());

-- ========================================
-- 3. order_items table
-- ========================================
ALTER TABLE dbo.order_items ENABLE ROW LEVEL SECURITY;

-- Users can view order_items only if they belong to their orders
CREATE POLICY "Users can view own order items" ON dbo.order_items
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM dbo.orders o 
    WHERE o.id = order_items.order_id 
      AND o.user_id = auth.uid()
  )
);

-- Users can insert order_items only if they belong to their orders
CREATE POLICY "Users can insert own order items" ON dbo.order_items
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM dbo.orders o 
    WHERE o.id = order_items.order_id 
      AND o.user_id = auth.uid()
  )
);

-- Users can update order_items only if they belong to their orders
CREATE POLICY "Users can update own order items" ON dbo.order_items
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM dbo.orders o 
    WHERE o.id = order_items.order_id 
      AND o.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM dbo.orders o 
    WHERE o.id = order_items.order_id 
      AND o.user_id = auth.uid()
  )
);

-- Users can delete order_items only if they belong to their orders
CREATE POLICY "Users can delete own order items" ON dbo.order_items
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM dbo.orders o 
    WHERE o.id = order_items.order_id 
      AND o.user_id = auth.uid()
  )
);

-- ========================================
-- 4. items_catalog table
-- ========================================
ALTER TABLE dbo.items_catalog ENABLE ROW LEVEL SECURITY;

-- Any user, including non-logged-in, can read items catalog
CREATE POLICY "Public read access" ON dbo.items_catalog
FOR SELECT
USING (true);

-- Admins can modify items_catalog
CREATE POLICY "Admins full access" ON dbo.items_catalog
FOR ALL
USING (auth.role() = 'admin')
WITH CHECK (auth.role() = 'admin');

-- ========================================
-- 5. item_history table
-- ========================================
ALTER TABLE dbo.item_history ENABLE ROW LEVEL SECURITY;

-- Only admins can read item history
CREATE POLICY "Admins can view item history" ON dbo.item_history
FOR SELECT
USING (auth.role() = 'admin');

-- No manual insert allowed
CREATE POLICY "No manual insert into item_history" ON dbo.item_history
FOR INSERT
WITH CHECK (false);

-- No manual update allowed
CREATE POLICY "No manual update of item_history" ON dbo.item_history
FOR UPDATE
USING (false)
WITH CHECK (false);

-- No manual delete allowed
CREATE POLICY "No manual delete from item_history" ON dbo.item_history
FOR DELETE
USING (false);
