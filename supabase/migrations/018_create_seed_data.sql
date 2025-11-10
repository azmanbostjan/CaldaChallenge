-- =============================================
-- Migration: 001_create_seed_data_enum_fixed.sql
-- Description: Create public.seed_data table and insert initial test data
-- =============================================

-- Create table for seeds
CREATE TABLE IF NOT EXISTS seed_data (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL, -- 'user', 'catalog_item', or 'order'
    payload JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- =============================================
-- Insert Users with UUIDs and proper status
-- =============================================
INSERT INTO seed_data (type, payload)
VALUES
  ('user', '{
    "id": "11111111-1111-1111-1111-111111111111",
    "email": "azmanbostjan+1@gmail.com",
    "password": "password123",
    "status": "Active",
    "name": "User 1",
    "role": "Active"
  }'::jsonb),
  ('user', '{
    "id": "22222222-2222-2222-2222-222222222222",
    "email": "azmanbostjan+2@gmail.com",
    "password": "password123",
    "status": "Active",
    "name": "User 2",
    "role": "Active"
  }'::jsonb),
  ('user', '{
    "id": "33333333-3333-3333-3333-333333333333",
    "email": "azmanbostjan+3@gmail.com",
    "password": "password123",
    "status": "Active",
    "name": "User 3",
    "role": "Active"
  }'::jsonb),
  ('user', '{
    "id": "44444444-4444-4444-4444-444444444444",
    "email": "azmanbostjan+admin@gmail.com",
    "password": "password123",
    "status": "Active",
    "name": "Admin",
    "role": "Active"
  }'::jsonb),
  ('user', '{
    "id": "55555555-5555-5555-5555-555555555555",
    "email": "azmanbostjan+4@gmail.com",
    "password": "password123",
    "status": "Active",
    "name": "User 4",
    "role": "Active"
  }'::jsonb);

-- =============================================
-- Insert Catalog Items with UUIDs and proper enums
-- =============================================
INSERT INTO seed_data (type, payload)
VALUES
  ('catalog_item', '{
    "id": "aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1",
    "name": "Laptop",
    "description": "High-end laptop",
    "price": 1500,
    "stock": 10,
    "status": "Available"
  }'::jsonb),
  ('catalog_item', '{
    "id": "aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2",
    "name": "Mouse",
    "description": "Wireless mouse",
    "price": 50,
    "stock": 50,
    "status": "Available"
  }'::jsonb),
  ('catalog_item', '{
    "id": "aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3",
    "name": "Keyboard",
    "description": "Mechanical keyboard",
    "price": 120,
    "stock": 30,
    "status": "Available"
  }'::jsonb),
  ('catalog_item', '{
    "id": "aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4",
    "name": "Monitor",
    "description": "27-inch monitor",
    "price": 300,
    "stock": 20,
    "status": "Available"
  }'::jsonb),
  ('catalog_item', '{
    "id": "aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5",
    "name": "USB-C Cable",
    "description": "Fast charging cable",
    "price": 15,
    "stock": 100,
    "status": "Available"
  }'::jsonb),
  ('catalog_item', '{
    "id": "aaaaaaa6-aaaa-aaaa-aaaa-aaaaaaaaaaa6",
    "name": "Webcam",
    "description": "HD webcam",
    "price": 80,
    "stock": 25,
    "status": "Available"
  }'::jsonb),
  ('catalog_item', '{
    "id": "aaaaaaa7-aaaa-aaaa-aaaa-aaaaaaaaaaa7",
    "name": "Headset",
    "description": "Noise-cancelling headset",
    "price": 200,
    "stock": 15,
    "status": "Available"
  }'::jsonb),
  ('catalog_item', '{
    "id": "aaaaaaa8-aaaa-aaaa-aaaa-aaaaaaaaaaa8",
    "name": "External HDD",
    "description": "1TB external hard drive",
    "price": 100,
    "stock": 40,
    "status": "Available"
  }'::jsonb);

-- =============================================
-- Insert Orders with user_email and proper items
-- =============================================
INSERT INTO seed_data (type, payload)
VALUES
  ('order', '{
    "user_email": "azmanbostjan+1@gmail.com",
    "shipping_address": "123 Maple St",
    "recipient_name": "Azman 1",
    "status": "Basket",
    "items": [
      {"item_name": "Laptop", "quantity": 1},
      {"item_name": "Mouse", "quantity": 2}
    ],
    "created_at": "2025-11-01T10:00:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+2@gmail.com",
    "shipping_address": "456 Oak Ave",
    "recipient_name": "Azman 2",
    "status": "Basket",
    "items": [
      {"item_name": "Keyboard", "quantity": 1},
      {"item_name": "Mouse", "quantity": 1}
    ],
    "created_at": "2025-11-02T12:00:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+3@gmail.com",
    "shipping_address": "789 Pine Rd",
    "recipient_name": "Azman 3",
    "status": "Basket",
    "items": [
      {"item_name": "Monitor", "quantity": 2},
      {"item_name": "USB-C Cable", "quantity": 3}
    ],
    "created_at": "2025-11-05T15:30:00Z"
  }'::jsonb),
  ('order', '{
    "user_email": "azmanbostjan+4@gmail.com",
    "shipping_address": "321 Cedar Ln",
    "recipient_name": "Azman 4",
    "status": "Basket",
    "items": [
      {"item_name": "Laptop", "quantity": 1},
      {"item_name": "Keyboard", "quantity": 2},
      {"item_name": "USB-C Cable", "quantity": 5}
    ],
    "created_at": "2025-11-07T09:45:00Z"
  }'::jsonb);
