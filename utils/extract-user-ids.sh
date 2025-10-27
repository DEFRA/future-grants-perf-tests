#!/bin/bash

# Script to fetch all users and extract performance test user emails with their IDs
BASE_URL="https://fg-cw-backend.perf-test.cdp-int.defra.cloud/users"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$PROJECT_ROOT/test-data/perf_test_user_ids.csv"

# Ensure test-data directory exists
mkdir -p "$PROJECT_ROOT/test-data"

echo "Fetching all users from $BASE_URL..."

# Create the CSV header
echo "email,id" > "$OUTPUT_FILE"

# Fetch all users and process the JSON response
curl -X 'GET' \
    "$BASE_URL" \
    -H 'accept: application/json' \
    -s | jq -r '
        .[] | 
        select(.email | test("^perf-tester-[0-9]{2}@defra\\.gov\\.uk$")) | 
        "\(.email),\(.id)"
    ' >> "$OUTPUT_FILE"

# Check if any data was written (beyond the header)
LINES_COUNT=$(wc -l < "$OUTPUT_FILE")
if [ "$LINES_COUNT" -gt 1 ]; then
    echo "Successfully extracted $(($LINES_COUNT - 1)) performance test user IDs to $OUTPUT_FILE"
    echo "Sample entries:"
    head -5 "$OUTPUT_FILE"
else
    echo "No performance test users found matching pattern 'perf-tester-XX@defra.gov.uk'"
fi