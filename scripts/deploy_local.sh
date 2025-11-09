#!/usr/bin/env bash
# scripts/deploy_local.sh
# Deploy all edge functions locally and start Supabase

set -e

# Dependency checks
if ! command -v npx &> /dev/null; then
  echo "npx not found. Please install Node.js and npm."
  exit 1
fi

if ! npx supabase --version &> /dev/null; then
  echo "Supabase CLI not found. Install it with: npm install -g supabase"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FUNCTIONS_DIR="$ROOT_DIR/supabase/functions"

echo "Deploying all edge functions locally..."
for dir in "$FUNCTIONS_DIR"/*/; do
  func_name=$(basename "$dir")
  echo "Deploying function: $func_name"
  npx supabase functions deploy "$func_name" --no-verify-jwt || echo "Failed to deploy $func_name, continuing..."
done

echo "Starting Supabase locally..."
npx supabase start

echo "Local setup complete. Supabase running at http://localhost:54321"
