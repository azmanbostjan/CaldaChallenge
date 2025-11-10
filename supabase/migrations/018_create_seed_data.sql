-- =============================================
-- Migration: 001_create_seed_data.sql
-- Description: Create public.seed_data table and insert initial test data
-- =============================================

-- Create table for seeds
CREATE TABLE IF NOT EXISTS public.seed_data (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL, -- 'user', 'catalog_item', or 'order'
    payload JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Insert users
INSERT INTO public.seed_data (type, payload)
VALUES
  ('user', '{"email": "azmanbostjan+1@gmail.com", "password": "password123", "role": "user"}'::jsonb),
  ('user', '{"email": "azmanbostjan+2@gmail.com", "password": "password123", "role": "user"}'::jsonb),
  ('user', '{"email": "azmanbostjan+3@gmail.com", "password": "password123", "role": "user"}'::jsonb),
  ('user', '{"email": "azmanbostjan+admin@gmail.com", "password": "password123", "role": "admin"}'::jsonb),
  ('user', '{"email": "azmanbostjan+4@gmail.com", "password": "password123", "role": "user"}'::jsonb);

-- Insert catalog items
INSERT INTO public.seed_data (type, payload)
VALUES
  ('catalog_item', '{"name": "Laptop", "description": "High-end laptop", "price": 1500, "stock": 10, "status": "Available"}'::jsonb),
  ('catalog_item', '{"name": "Mouse", "description": "Wireless mouse", "price": 50, "stock": 50, "status": "Available"}'::jsonb),
  ('catalog_item', '{"name": "Keyboard", "description": "Mechanical keyboard", "price": 120, "stock": 30, "status": "Available"}'::jsonb),
  ('catalog_item', '{"name": "Monitor", "description": "27-inch monitor", "price": 300, "stock": 20, "status": "Available"}'::jsonb),
  ('catalog_item', '{"name": "USB-C Cable", "description": "Fast charging cable", "price": 15, "stock": 100, "status": "Available"}'::jsonb),
  ('catalog_item', '{"name": "Webcam", "description": "HD webcam", "price": 80, "stock": 25, "status": "Available"}'::jsonb),
  ('catalog_item', '{"name": "Headset", "description": "Noise-cancelling headset", "price": 200, "stock": 15, "status": "Available"}'::jsonb),
  ('catalog_item', '{"name": "External HDD", "description": "1TB external hard drive", "price": 100, "stock": 40, "status": "Available"}'::jsonb);

-- Insert orders
INSERT INTO public.seed_data (type, payload)
VALUES
  ('order', '{
    "user_email": "azmanbostjan+1@gmail.com",
    "shipping_address": "123 Maple St",
    "recipient_name": "Azman 1",
    "status": "Pending",
    "items": [{"item_name": "Laptop", "quantity": 1}, {"item_name": "Mouse", "quantity": 2}],
    "created_at": "2025-11-01T10:00:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+2@gmail.com",
    "shipping_address": "456 Oak Ave",
    "recipient_name": "Azman 2",
    "status": "Pending",
    "items": [{"item_name": "Keyboard", "quantity": 1}, {"item_name": "Mouse", "quantity": 1}],
    "created_at": "2025-11-02T12:00:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+3@gmail.com",
    "shipping_address": "789 Pine Rd",
    "recipient_name": "Azman 3",
    "status": "Pending",
    "items": [{"item_name": "Monitor", "quantity": 2}, {"item_name": "USB-C Cable", "quantity": 3}],
    "created_at": "2025-11-05T15:30:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+4@gmail.com",
    "shipping_address": "321 Cedar Ln",
    "recipient_name": "Azman 4",
    "status": "Pending",
    "items": [{"item_name": "Laptop", "quantity": 1}, {"item_name": "Keyboard", "quantity": 2}, {"item_name": "USB-C Cable", "quantity": 5}],
    "created_at": "2025-11-07T09:45:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+1@gmail.com",
    "shipping_address": "123 Maple St",
    "recipient_name": "Azman 1",
    "status": "Pending",
    "items": [{"item_name": "Webcam", "quantity": 1}, {"item_name": "Headset", "quantity": 1}],
    "created_at": "2025-10-28T14:00:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+2@gmail.com",
    "shipping_address": "456 Oak Ave",
    "recipient_name": "Azman 2",
    "status": "Pending",
    "items": [{"item_name": "External HDD", "quantity": 2}],
    "created_at": "2025-10-25T16:20:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+3@gmail.com",
    "shipping_address": "789 Pine Rd",
    "recipient_name": "Azman 3",
    "status": "Pending",
    "items": [{"item_name": "Headset", "quantity": 1}, {"item_name": "USB-C Cable", "quantity": 2}],
    "created_at": "2025-10-29T11:10:00Z"
  }'::jsonb);
