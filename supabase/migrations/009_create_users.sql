CREATE TYPE dbo.user_status AS ENUM ('Active','Inactive','Blocked');

CREATE TABLE dbo.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    name TEXT,
    status dbo.user_status NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_status ON dbo.users(status);
