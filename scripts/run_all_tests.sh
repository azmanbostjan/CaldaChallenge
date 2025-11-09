#!/bin/bash
set -e

TEST_DIR="tests"
FAILED=()  # Array to hold failed tests

echo "Running Supabase test suite..."

# Loop over all .sql files in the tests directory
for f in "$TEST_DIR"/*.sql; do
    [ -e "$f" ] || continue  # Skip if no files found

    echo "--------------------------------------"
    echo "Running $(basename "$f")"

    if npx supabase db query "$f"; then
        echo "$(basename "$f") PASSED"
    else
        echo "$(basename "$f") FAILED"
        FAILED+=("$(basename "$f")")
    fi
done

echo "--------------------------------------"
if [ ${#FAILED[@]} -eq 0 ]; then
    echo "All tests PASSED 🎉"
else
    echo "The following tests FAILED ❌:"
    for t in "${FAILED[@]}"; do
        echo " - $t"
    done
    exit 1
fi
