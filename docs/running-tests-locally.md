# Running Performance Tests Locally

## Overview

The full local flow is:

1. Ensure test data is seeded in `perf-test` environment
2. Generate session cookies into `data/session-cookies.csv`
3. Ensure case refs CSV exists at `data/perf_test_case_refs_frps.csv`
4. Open JMeter, configure for local, and run

---

## Prerequisites

- JMeter installed: `/opt/homebrew/Cellar/jmeter/5.6.3/bin/jmeter`
- Access to `perf-test` CDP environment
- Your CDP Developer API key (from CDP portal)
- `auth/run/.env` file exists with valid credentials (see below)

---

## Step 1 — Seed test data in perf-test

Cases must exist in the perf-test environment before running. This is done by deploying hotfix branches. See `docs/perf-test-seeding.md` for full details.

**Quick check** — verify cases exist:
```
https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases
```
If cases are visible, skip to Step 2.

---

## Step 2 — Configure `.env`

File is at `auth/run/.env`. Verify credentials are current:

```env
ENTRA_ID_USERNAME=sa-fgcw.writer@defra.onmicrosoft.com
ENTRA_ID_PASSWORD=<current-password>
APP_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/
CASES_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases
COOKIE_NAME=session
EXPECTED_DOMAIN=fg-cw-frontend
OUTPUT_FILE=./artifacts/cw-fe-session.json
```

> **Note:** `COOKIE_NAME` is `session` — not `CW-FE` as some older docs say.

---

## Step 3 — Generate session cookies

```bash
cd future-grants-perf-tests/auth/run
npm install          # only needed if node_modules is missing
npm run entra-login:multi
```

This runs headless Chrome 10 times, logging in via Entra ID each time and appending the session cookie to `data/session-cookies.csv`.

**What it produces:**
```
data/session-cookies.csv
cookieHeader
session=<value1>
session=<value2>
...
session=<value10>
```

**Cookies expire after 4 hours.** Regenerate them before each test run.

### Troubleshooting cookie generation

**Error: `net::ERR_PROXY_CONNECTION_FAILED`**
You're running `npm run entra-login` directly instead of `entra-login:multi`. The bare `entra-login` command uses a proxy (`localhost:3128`) meant for CDP. Use `entra-login:multi` locally — it sets `LOCAL=true` which skips the proxy.

**Debug a single login (visible browser):**
```bash
npm run entra-login:debug
```
This opens a visible browser so you can see what's happening. Useful for troubleshooting login failures. To use it for cookie generation, first create the CSV header manually:
```bash
echo "cookieHeader" > ../../data/session-cookies.csv
npm run entra-login:debug   # repeat as needed
```

**Error: `This version of ChromeDriver only supports Chrome version X`**
The `chromedriver` npm package is behind your Chrome version. Update it:
```bash
npm install chromedriver@<your-chrome-major-version>
# e.g. npm install chromedriver@148
```

---

## Step 4 — Verify case refs CSV

File must exist at `data/perf_test_case_refs_frps.csv` and match the cases seeded in perf-test (default: 100 cases, `perf-test-00000` to `perf-test-00099`).

Check it exists and has the right count:
```bash
wc -l data/perf_test_case_refs_frps.csv
# should be 101 (100 case refs + 1 header line)
```

If missing or wrong, regenerate:
```bash
echo "caseRef" > data/perf_test_case_refs_frps.csv
for i in $(seq 0 99); do printf "perf-test-%05d\n" $i >> data/perf_test_case_refs_frps.csv; done
```

---

## Step 5 — Configure JMeter for local

Launch JMeter:
```bash
/opt/homebrew/Cellar/jmeter/5.6.3/bin/jmeter
```

Open `scenarios/cw-journey-complete.jmx`.

Navigate to **Test Plan → User Defined Variables** and update these 3 values:

| Variable | CDP default (do not commit) | Local value |
|---|---|---|
| `BASE_URL_2` | `fg-cw-backend.perf-test.cdp-int.defra.cloud` | `ephemeral-protected.api.perf-test.cdp-int.defra.cloud` |
| `PATH_PREFIX` | *(empty)* | `/fg-cw-backend` |
| `API_KEY` | *(empty)* | Your CDP Developer API key |

> The API key is needed locally because requests go through the ephemeral gateway, which requires `x-api-key` authentication. In CDP the service is accessed directly with no key required.

---

## Step 6 — Run

Click the green **Play** button in JMeter. Results appear in `test-results/`.

---

## Step 7 — Revert JMeter config after testing

**Important:** Do not commit the local variable changes.

```bash
git checkout scenarios/cw-journey-complete.jmx
```

---

## Common errors

| Error | Cause | Fix |
|---|---|---|
| `caseId must only contain hexadecimal characters` | Cases not seeded in perf-test | Deploy hotfix branches, wait for seeding to complete |
| `404` on case ref lookup | `perf_test_case_refs_frps.csv` doesn't match seeded data | Regenerate CSV to match `PERF_TEST_COUNT` |
| `401` / `403` during test | Session cookies expired (4 hour limit) | Regenerate cookies with `npm run entra-login:multi` |
| `ERR_PROXY_CONNECTION_FAILED` | Running `npm run entra-login` directly | Use `npm run entra-login:multi` or `entra-login:debug` instead |
| `ChromeDriver only supports Chrome version X` | Chromedriver version behind Chrome | `npm install chromedriver@<chrome-major-version>` in `auth/run/` |
