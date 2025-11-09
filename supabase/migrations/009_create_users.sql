CREATE TYPE user_status AS ENUM ('Active','Inactive','Blocked');

CREATE TABLE dbo.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    name TEXT,
    status user_status NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_status ON users(status);