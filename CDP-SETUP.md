# CDP Test Suite Setup

This document explains how to configure and run the performance test suite in CDP.

## Overview

The test suite requires session cookies to be generated before running JMeter tests. This is done automatically by a pre-test script that handles Entra ID authentication.

## Prerequisites

CDP test runner must have:
- **Node.js 18+** installed
- **Chrome browser** + **Chromedriver** installed
- **JMeter** installed (for running the actual tests)

## Required Environment Variables

Configure these secrets in CDP portal (Test Suites > future-grants-perf-tests > Secrets):

| Variable | Description | Example |
|----------|-------------|---------|
| `ENTRA_ID_USERNAME` | Service account username | `sa-fgcw.writer@defra.onmicrosoft.com` |
| `ENTRA_ID_PASSWORD` | Service account password | `********` |
| `COOKIE_COUNT` | Number of cookies to generate (optional) | `10` (default) |

## How to Run Tests

### Option 1: Run Pre-Test Script (Recommended)

The `run-tests.sh` script handles everything:

```bash
# Set environment variables (if not already set in CDP)
export ENTRA_ID_USERNAME="sa-fgcw.writer@defra.onmicrosoft.com"
export ENTRA_ID_PASSWORD="your-password"
export COOKIE_COUNT=10  # Optional, defaults to 10

# Run the pre-test setup script
./run-tests.sh
```

This script will:
1. Install auth dependencies (`npm ci` in `auth/run`)
2. Generate session cookies (10 cookies by default)
3. Save cookies to `data/session-cookies.csv`
4. Exit with status 0 if successful, non-zero if failed

After this completes, CDP should run JMeter tests normally.

### Option 2: Manual Steps

If CDP cannot run the wrapper script, configure it to run these commands:

```bash
# Step 1: Install dependencies
cd auth/run
npm ci

# Step 2: Generate cookies
npm run entra-login:multi 10

# Step 3: Verify cookies generated
cd ../..
if [ ! -f data/session-cookies.csv ]; then
  echo "Failed to generate cookies"
  exit 1
fi
```

## Test Execution Flow

```
┌─────────────────────────────────────────────┐
│ CDP Triggers Test Run                       │
└───────────────┬─────────────────────────────┘
                │
                v
┌─────────────────────────────────────────────┐
│ 1. Run: ./run-tests.sh                      │
│    - Installs Node deps                     │
│    - Generates session cookies              │
│    - Saves to data/session-cookies.csv      │
└───────────────┬─────────────────────────────┘
                │
                v
┌─────────────────────────────────────────────┐
│ 2. CDP Runs JMeter Tests                    │
│    - Uses cookies from CSV file             │
│    - Executes test scenarios                │
└───────────────┬─────────────────────────────┘
                │
                v
┌─────────────────────────────────────────────┐
│ 3. Test Results                              │
└─────────────────────────────────────────────┘
```

## Files Generated

| File | Description | Committed to Git? |
|------|-------------|-------------------|
| `data/session-cookies.csv` | Session cookies for JMeter | ❌ No (in .gitignore) |
| `auth/run/artifacts/*.json` | Cookie metadata (debugging) | ❌ No (in .gitignore) |

## Troubleshooting

### Error: "Required environment variables not set"

**Cause**: `ENTRA_ID_USERNAME` or `ENTRA_ID_PASSWORD` not configured in CDP.

**Fix**: Add these to CDP Secrets (see "Required Environment Variables" above).

### Error: "Failed to generate session cookies"

**Cause**: Login failed or Chrome/Chromedriver not available.

**Fix**:
1. Verify credentials are correct
2. Ensure Chrome and Chromedriver are installed in CDP runner
3. Check logs for specific WebDriver errors

### Error: "npm: command not found"

**Cause**: Node.js not installed in CDP test runner.

**Fix**: Ensure CDP test runner image includes Node.js 18+.

### Error: "chrome: command not found"

**Cause**: Chrome browser not installed.

**Fix**: Ensure CDP test runner image includes Chrome browser and Chromedriver.

## Local Testing

To test the setup locally:

```bash
# Set environment variables
export ENTRA_ID_USERNAME="your-username"
export ENTRA_ID_PASSWORD="your-password"

# Run the pre-test script
./run-tests.sh

# Verify cookies were generated
cat data/session-cookies.csv
```

## Notes

- Session cookies typically expire after 8-24 hours (depending on Entra ID config)
- Cookies are regenerated fresh on every test run
- The script generates 10 cookies by default (configurable via `COOKIE_COUNT`)
- Multiple cookies allow parallel test execution in JMeter
- Credentials are never committed to git (only stored as CDP secrets)
