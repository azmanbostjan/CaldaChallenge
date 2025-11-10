#!/usr/bin/env bash
# scripts/deploy_local.sh
# Start Supabase locally, serve functions, and call init

set -e

# -----------------------------
# 1. Load environment variables
# -----------------------------
if [ -f .env ]; then
  echo "Loading environment variables from .env"
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found. Exiting."
  exit 1
fi

# -----------------------------
# 2. Start Supabase stack
# -----------------------------
echo "Starting local Supabase..."
npx supabase start

# -----------------------------
# 3. Serve functions locally in background
# -----------------------------
echo "Serving all edge functions locally..."
# & to run in background so the script can continue
npx supabase functions serve --no-verify-jwt &
SERVE_PID=$!

# Wait a few seconds to make sure Supabase + Functions are fully up
echo "Waiting 5 seconds for functions to be ready..."
sleep 5

# -----------------------------11
# 4. Call init function with local anon key
# -----------------------------
echo "Calling init function..."
if [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "SUPABASE_ANON_KEY is not set. Make sure it is exported in .env."
  exit 1
fi

curl -i \
  --location \
  --request POST "http://127.0.0.1:54321/functions/v1/init" \
  --header "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  --header "Content-Type: application/json" \
  --data '{"name":"Functions"}'

echo "Local deployment complete. Functions are being served with PID $SERVE_PID."
echo "You can stop serving functions with: kill $SERVE_PID"