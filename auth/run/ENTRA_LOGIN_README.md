# Entra ID Login and Session Cookie Extraction

This setup performs Entra ID (Microsoft) authentication and extracts the CW-FE session cookie for use in JMeter performance tests.

## Setup

### 1. Install Dependencies

```bash
cd /Users/nitinmali/workspace/farming/future-grants-perf-tests/auth/run
npm install
```

### 2. Configure Environment Variables

Create a `.env` file from the template:

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```env
ENTRA_ID_USERNAME=your-email@example.com
ENTRA_ID_PASSWORD=your-password
APP_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/
EXPECTED_DOMAIN=fg-cw-frontend
COOKIE_NAME=CW-FE
CASES_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases
CASE_HREF=/cases/695cefcf55689bcb16d66afa
OUTPUT_FILE=./artifacts/cw-fe-session.json
```

## Running the Login Script

### Normal Mode (Headless)

```bash
npm run entra-login
```

This will:
- Run Chrome in headless mode
- Navigate to your application
- Perform Entra ID authentication
- Assert we're on the correct domain
- Navigate to the cases page (to force session creation)
- Click on a specific case (to ensure full session is established)
- Extract all cookies including the CW-FE session cookie
- Save them to `artifacts/cw-fe-session.json`

### Debug Mode (Visible Browser)

```bash
npm run entra-login:debug
```

This will:
- Run Chrome in visible mode (you can see what's happening)
- Provide detailed debug output
- Useful for troubleshooting login issues

## Output

The script generates a JSON file at `artifacts/cw-fe-session.json` with this structure:

```json
{
  "createdAt": "2026-01-08T19:00:00.000Z",
  "expectedDomain": "fg-cw-frontend",
  "appSessionCookieName": "CW-FE",
  "cookie": {
    "name": "CW-FE",
    "value": "session-token-value",
    "domain": ".fg-cw-frontend.perf-test.cdp-int.defra.cloud",
    "path": "/",
    "httpOnly": true,
    "secure": true
  },
  "allCookies": [
    // Array of all cookies from the browser for reference
  ],
  "cookieHeader": "CW-FE=session-token-value"
}
```

## Using with JMeter

### Option 1: Cookie Manager

1. Add an HTTP Cookie Manager to your Thread Group
2. Add a cookie with:
   - Name: `CW-FE` (from the JSON)
   - Value: The `cookie.value` from the JSON
   - Domain: The `cookie.domain` from the JSON
   - Path: `/`

### Option 2: HTTP Header

1. Add an HTTP Header Manager to your Thread Group
2. Add a header:
   - Name: `Cookie`
   - Value: Use the `cookieHeader` value from the JSON (e.g., `CW-FE=session-token-value`)

## Troubleshooting

### Cookie Not Found

If you get "could not find cookie" error:
- Check that `COOKIE_NAME` in `.env` matches your application's actual cookie name
- Run in debug mode to see what cookies are available
- Check browser DevTools Network tab to see what cookies your app sets

### Login Fails

- Verify credentials in `.env` are correct
- Run in debug mode to see where it's failing
- Check that `APP_URL` is correct
- Ensure you have network access to the application

### Timeout Errors

- Increase timeout in `wdio.entra.conf.js` (mochaOpts.timeout)
- Check network connectivity
- Run in debug mode to see what's happening

## Files

- `test/utils/loginHelper.js` - Entra ID login helper functions
- `test/specs/entra-login-dump.e2e.js` - Test spec that performs login and dumps cookie
- `wdio.entra.conf.js` - WebdriverIO configuration for Entra ID login
- `.env` - Environment variables (you create this)
- `artifacts/cw-fe-session.json` - Output file with session cookie

## Notes

- The session cookie typically expires after some time (varies by application)
- Run this script before each JMeter test run to get a fresh cookie
- Store credentials securely and never commit `.env` to version control
