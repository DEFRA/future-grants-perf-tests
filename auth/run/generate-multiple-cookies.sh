#!/bin/bash

# Script to generate multiple session cookies for JMeter load testing
# Usage: ./generate-multiple-cookies.sh [number_of_cookies]

COUNT=${1:-10}  # Default to 10 if no argument provided

echo "========================================"
echo "Generating $COUNT session cookies"
echo "========================================"

# Clear existing CSV file
CSV_FILE="../../test-data/session-cookies.csv"
rm -f "$CSV_FILE"
echo "✓ Cleared existing cookies"

# Generate cookies
for i in $(seq 1 $COUNT); do
    echo ""
    echo "=== Generating cookie $i/$COUNT ==="
    npm run entra-login

    if [ $? -ne 0 ]; then
        echo "❌ Failed to generate cookie $i"
        exit 1
    fi

    # Small delay between runs to avoid rate limiting
    if [ $i -lt $COUNT ]; then
        echo "Waiting 2 seconds before next login..."
        sleep 2
    fi
done

echo ""
echo "========================================"
echo "✓ Successfully generated $COUNT cookies"
echo "✓ Saved to: $CSV_FILE"
echo "========================================"

# Show summary
if [ -f "$CSV_FILE" ]; then
    COOKIE_COUNT=$(tail -n +2 "$CSV_FILE" | wc -l)
    echo "Total cookies in CSV: $COOKIE_COUNT"
fi
