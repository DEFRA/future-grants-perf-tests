#!/bin/bash

# Script to extract performance test case references with their IDs from JSON file
# Only extracts cases with status "NEW"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INPUT_FILE="$PROJECT_ROOT/data/all-cases.json"
OUTPUT_FILE="$PROJECT_ROOT/data/perf_test_case_refs_frps.csv"

# Ensure data directory exists
mkdir -p "$PROJECT_ROOT/data"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE not found"
    exit 1
fi

echo "Extracting case references from $INPUT_FILE..."
echo "Filtering for cases with status: NEW"

# Create the CSV header
echo "caseRef,_id" > "$OUTPUT_FILE"

# Extract cases with status "NEW" and matching caseRef pattern
jq -r '
    .[] | 
    select(.status == "NEW") |
    select(.caseRef | test("^frps-perf-test-client-ref-[0-9]+$")) | 
    "\(.caseRef),\(._id)"
' "$INPUT_FILE" >> "$OUTPUT_FILE"

# Check if any data was written (beyond the header)
LINES_COUNT=$(wc -l < "$OUTPUT_FILE")
if [ "$LINES_COUNT" -gt 1 ]; then
    echo "Successfully extracted $(($LINES_COUNT - 1)) NEW performance test case references to $OUTPUT_FILE"
    echo "Sample entries:"
    head -5 "$OUTPUT_FILE"
    echo ""
    echo "All extracted cases:"
    cat "$OUTPUT_FILE"
else
    echo "No NEW performance test case references found matching pattern 'frps-perf-test-client-ref-XXX'"
    echo "Available statuses in the JSON file:"
    jq -r '.[] | .status' "$INPUT_FILE" | sort | uniq -c
fi