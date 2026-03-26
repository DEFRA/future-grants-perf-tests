#!/bin/bash

set -e  # Exit on error

echo "========================================"
echo "Performance Test Runner"
echo "========================================"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTH_DIR="$SCRIPT_DIR/auth/run"
DATA_DIR="$SCRIPT_DIR/data"
COOKIE_COUNT=${COOKIE_COUNT:-10}  # Default to 10 cookies

# Check required environment variables
if [ -z "$ENTRA_ID_USERNAME" ] || [ -z "$ENTRA_ID_PASSWORD" ]; then
  echo "❌ ERROR: Required environment variables not set"
  echo "   Please set: ENTRA_ID_USERNAME, ENTRA_ID_PASSWORD"
  exit 1
fi

echo ""
echo "=== Step 1: Installing auth dependencies ==="
cd "$AUTH_DIR"
if [ ! -d "node_modules" ]; then
  echo "Installing npm packages..."
  npm ci
else
  echo "✓ Dependencies already installed"
fi

echo ""
echo "=== Step 2: Generating session cookies ==="
npm run entra-login:clear
./generate-multiple-cookies.sh "$COOKIE_COUNT"

# Verify CSV was created
if [ ! -f "$DATA_DIR/session-cookies.csv" ]; then
  echo "❌ Failed to generate session cookies"
  exit 1
fi

COOKIE_COUNT_ACTUAL=$(tail -n +2 "$DATA_DIR/session-cookies.csv" | wc -l | tr -d ' ')
echo "✓ Generated $COOKIE_COUNT_ACTUAL session cookies"

echo ""
echo "=== Step 3: Ready to run tests ==="
echo "Session cookies are available at: $DATA_DIR/session-cookies.csv"
echo ""
echo "CDP should now run JMeter tests using the generated cookies."
echo "The JMeter script is configured to read from data/session-cookies.csv"
echo ""
echo "========================================"
echo "✓ Pre-test setup complete"
echo "========================================"
