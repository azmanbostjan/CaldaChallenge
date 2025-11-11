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

# Prompt for Supabase service role key (hidden input)
read -sp "Enter your Supabase SERVICE_KEY: " SERVICE_KEY
echo

# Export it so it can be used by curl
export SERVICE_KEY

# Construct the function URL dynamically using the project ref
INIT_URL="https://${PROJECT_REF}.functions.supabase.co/init"

# Trigger the init function
curl -s -X POST "$INIT_URL" \
  -H "Authorization: Bearer $SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'

echo "Init function triggered at $INIT_URL"