# CaldaChallenge Backend Project

## Project Overview
CaldaChallenge is a backend-only Supabase project simulating a simple e-commerce system. It uses PostgreSQL, Supabase Auth, Edge Functions (Deno + TypeScript), and declarative schema with migrations. Key features include:

- User management (roles: admin, user, guest)
- Catalog items with history tracking
- Orders and order items
- Row-Level Security (RLS) enforcing access per role
- Cron job for archiving old orders to staging tables
- KPI computation for marketing and performance metrics
- Create_order checks if item is in stock, if not it rejects the order, if in stock it decreases stock amount by ordered amount

Author's notes:
Because job scheduler is not available locally, i recommend pushing to prod or running scheduled functions manually.
Edge functions are not published with code using supabase start, so i added a bash script to publish all edge function before calling supabase start
Commands are prefixed with npx, as i installed Supabase under a local user


## Project Structure
```
CaldaChallenge/
├─ scripts/
├─ supabase/
│ ├─ functions/ # Edge functions (create_user, create_order, cron jobs)
│ ├─ migrations/ # Table creation, triggers, RLS, views
│ ├─ seeds/ # Initial data
│ └─ config.toml # Supabase CLI config
├─ tests/ # SQL scripts for RLS and other backend tests
├─ README.md
```
## Db schema diagram url:
https://dbdiagram.io/d/6910db506735e11170f27c67

## Getting Started prod
1. **Start local Supabase:**
./scripts/deploy_prod.sh
2. **Test RLS and backend logic**
npx supabase db query tests/test_user_orders.sql
npx supabase db query tests/test_admin_access.sql

## Getting Started local
1. **Start local Supabase:**
./scripts/deploy_local.sh
2. **Seed the db**
npx supabase functions serve init

3. **Archive old orders manually**
npx supabase functions invoke archive_old_folders
4. **Test RLS and backend logic**
npx supabase db query tests/test_user_orders.sql
npx supabase db query tests/test_admin_access.sql