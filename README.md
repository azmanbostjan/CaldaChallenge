# CaldaChallenge Backend Project

## Project Overview
CaldaChallenge is a backend-only Supabase project simulating a simple e-commerce system. It uses PostgreSQL, Supabase Auth, Edge Functions (Deno + TypeScript), and declarative schema with migrations. Key features include:

- User creation
- Catalog items with history tracking
- Orders and order items
- Row-Level Security (RLS) enforcing access per role
- Cron job for archiving old orders to staging tables
- KPI computation for marketing and performance metrics
- Create order checks if all items are in stock, throws error if not, and decreases the stock by orderd amount after creating order

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


**Project credentials**
email: azmanbostjan@gmail.com,
password: Caldachallenge123!

## Getting Started prod
1. **Start local Supabase:**
./scripts/deploy_prod.sh

## Getting Started local
1. **Start local Supabase:**
./scripts/deploy_local.sh

**Dev log**
Author's notes:
Because job scheduler is not available locally, i recommend pushing to prod or running scheduled functions manually.
Edge functions are not published with code using supabase start, so i added a bash script to publish all edge function before calling supabase start
Commands are prefixed with npx, as i installed Supabase under a local user
Tests are meant to be run in prod env SQL editor.

**TODOS**
- ensure views are exposed only to admin users
- optimise RLS policies
- add guest role for users that are not logged and can only see item catalog
- expand item history to include all columns from items_catalog, currently it triggers on change to any column for CRUD operations, but only records price changes in table
- refactor tables between schemas: dbo, vw, stg (currently all public to get edge functions working)
- add sql transactional support with rollback