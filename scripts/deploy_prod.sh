#!/usr/bin/env bash
# scripts/deploy_prod.sh
# Deploy all edge functions to production and push database

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

echo "Linking Supabase project..."
read -p "Enter your Supabase project ref: " PROJECT_REF
npx supabase link --project-ref $PROJECT_REF

echo "Deploying all edge functions..."
for dir in "$FUNCTIONS_DIR"/*/; do
  func_name=$(basename "$dir")
  echo "Deploying function: $func_name"
  # Removed --no-verify-jwt flag to avoid decorator warning
  npx supabase functions deploy "$func_name" || echo "Failed to deploy $func_name, continuing..."
done

echo "Pushing database migrations and seed data..."
npx supabase db push

echo "Production setup complete."
