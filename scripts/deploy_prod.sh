#!/usr/bin/env bash
# scripts/deploy_prod.sh
# Deploy all edge functions to production and push database migrations

set -euo pipefail

# -----------------------------
# 1. Dependency checks
# -----------------------------
if ! command -v npx &> /dev/null; then
  echo "npx not found. Please install Node.js and npm."
  exit 1
fi

if ! npx supabase --version &> /dev/null; then
  echo "Supabase CLI not found. Install it with: npm install -g supabase"
  exit 1
fi

# -----------------------------
# 2. Set paths
# -----------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FUNCTIONS_DIR="$ROOT_DIR/supabase/functions"

# -----------------------------
# 3. Link Supabase project
# -----------------------------
read -p "Enter your Supabase project ref: " PROJECT_REF
npx supabase link --project-ref "$PROJECT_REF"

# -----------------------------
# 4. Deploy all edge functions
# -----------------------------
echo "Deploying all edge functions..."
# Only deploy folders with an index.ts (skip schedule.ts)
for dir in "$FUNCTIONS_DIR"/*/; do
  if [[ -f "$dir/index.ts" || -f "$dir/index.js" ]]; then
    func_name=$(basename "$dir")
    echo "Deploying function: $func_name"
    npx supabase functions deploy "$func_name" || {
      echo "Failed to deploy $func_name, continuing..."
    }
  else
    echo "Skipping $dir (no index.ts or index.js found)"
  fi
done

# -----------------------------
# 5. Push database migrations
# -----------------------------
echo "Applying database migrations..."
npx supabase db push

echo "Production deployment complete."

# -----------------------------
# 6. Call init function
# -----------------------------
echo "Triggering init function..."
curl -s -X POST "https://meuaffzjyxsphdwyeany.functions.supabase.co/init" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ldWFmZnpqeXhzcGhkd3llYW55Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjQ2MDc0MSwiZXhwIjoyMDc4MDM2NzQxfQ.dJINYNyreXI0JYorWD_kV4DhWkbSCo8BL4yLtqZ1Yxg" \
  -H "Content-Type: application/json" \
  -d '{"name":"Functions"}'
echo "Init function triggered."
