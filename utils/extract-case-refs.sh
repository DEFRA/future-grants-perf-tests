#!/bin/bash

# Script to fetch all cases and extract performance test case references with their IDs
BASE_URL="https://fg-cw-backend.perf-test.cdp-int.defra.cloud/cases"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$PROJECT_ROOT/test-data/perf_test_case_refs.csv"

# Ensure test-data directory exists
mkdir -p "$PROJECT_ROOT/test-data"

echo "Fetching all cases from $BASE_URL..."

# Create the CSV header
echo "caseRef,_id" > "$OUTPUT_FILE"

# Fetch all cases and process the JSON response
curl -X 'GET' \
    "$BASE_URL" \
    -H 'accept: application/json' \
    -s | jq -r '
        .[] | 
        select(.caseRef | test("^perf-test-client-ref-[0-9]{3}$")) | 
        "\(.caseRef),\(._id)"
    ' >> "$OUTPUT_FILE"

# Check if any data was written (beyond the header)
LINES_COUNT=$(wc -l < "$OUTPUT_FILE")
if [ "$LINES_COUNT" -gt 1 ]; then
    echo "Successfully extracted $(($LINES_COUNT - 1)) performance test case references to $OUTPUT_FILE"
    echo "Sample entries:"
    head -5 "$OUTPUT_FILE"
else
    echo "No performance test case references found matching pattern 'perf-test-client-ref-XXX'"
fi