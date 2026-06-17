# How to Run Performance Tests

This guide covers running JMeter performance tests for the Future Grants platform in both CDP and local environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: Configure Test Data](#step-1-configure-test-data)
- [Step 2: Deploy Hotfix Branches](#step-2-deploy-hotfix-branches)
- [Step 3: Configure CDP Secrets](#step-3-configure-cdp-secrets)
- [Step 4: Run Tests in CDP](#step-4-run-tests-in-cdp)
- [Step 5: View Results](#step-5-view-results)
- [Running Tests Locally](#running-tests-locally)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before running tests, ensure:

- CDP Portal access with permissions to run test suites
- Access to CDP secrets management
- Hotfix branches deployed to `perf-test` environment:
  - `fg-gas-backend/hotfix/perf-test-seed`
  - `fg-cw-backend/hotfix/perf-test-seed`

---

## Step 1: Configure Test Data

### 1.1 Decide on Test Scale

Choose how many applications you want to test (e.g., 100, 500, 1000).

**Important:** Session cookies expire after 4 hours. With 10 concurrent threads:
- 100 applications ≈ 1 hour
- 500 applications ≈ 5 hours (will hit 2-hour test limit or cookie expiration)
- Recommended: **100-200 applications** for complete test runs

### 1.2 Update Case References CSV

Edit `data/perf_test_case_refs_frps.csv` to match your test count.

**Current state:** 100 case refs (perf-test-00000 to perf-test-00099)

**To generate more case refs:**

```bash
# Example: Generate 200 case refs
echo "caseRef" > data/perf_test_case_refs_frps.csv
for i in $(seq 0 199); do
  printf "perf-test-%05d\n" $i >> data/perf_test_case_refs_frps.csv
done
```

**Commit and push changes:**

```bash
git add data/perf_test_case_refs_frps.csv
git commit -m "Update test data to 200 case refs"
git push
```

---

## Step 2: Deploy Hotfix Branches

**Deploy CW first, then GAS.** CW must be running and its inbox subscriber ready before GAS publishes SQS messages. If GAS deploys first, CW's seed script will wipe any cases that arrived while CW was starting up.

### 2.1 Deploy fg-cw-backend Hotfix First

This creates test users and prepares CW to receive cases from GAS via SQS.

1. Navigate to CDP Portal → Deployments
2. Deploy `fg-cw-backend` branch `hotfix/perf-test-seed` to `perf-test` environment
3. Wait for deployment to complete
4. Check logs for: `⏭️  Perf test data already seeded with 2 test users, skipping` (or created if first time)

### 2.2 Deploy fg-gas-backend Hotfix Second

This seeds applications in GAS, which flow to CW as cases via SQS.

1. Navigate to CDP Portal → Deployments
2. Deploy `fg-gas-backend` branch `hotfix/perf-test-seed` to `perf-test` environment
3. Wait for deployment to complete
4. Check logs for: `✅ Performance test data seeding complete!`

### 2.3 Verify Seeding

**Option A: Check MongoDB**

```javascript
// GAS MongoDB
db.applications.countDocuments({ clientRef: /^perf-test-/ })
// Should match PERF_TEST_COUNT

db.outbox.countDocuments({ status: "PUBLISHED" })
// Should be > 0 (pending messages)

// CW MongoDB
db.cases.countDocuments({})
// Should match PERF_TEST_COUNT (after messages processed)

db.users.countDocuments({ _id: /^perf-test-user-/ })
// Should be 2 (test users)
```

**Option B: Check UI**

Navigate to `https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases` and verify cases exist.

---

## Step 3: Configure CDP Secrets

Navigate to: **CDP Portal → Test Suites → future-grants-perf-tests → Secrets**

Set the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `ENTRA_ID_USERNAME` | `sa-fgcw.writer@defra.onmicrosoft.com` | Service account for cookie generation |
| `ENTRA_ID_PASSWORD` | `********` | Service account password |
| `COOKIE_COUNT` | `10` | Number of session cookies (optional, defaults to 10) |

**Also verify these environment variables for the hotfix deployments:**

| Variable | Value | Where to Set |
|----------|-------|--------------|
| `PERF_TEST_SEED` | `true` | Both GAS and CW deployment configs |
| `PERF_TEST_COUNT` | `100` (or your chosen count) | Both GAS and CW deployment configs |

**CRITICAL:** `PERF_TEST_COUNT` must match the number of case refs in `perf_test_case_refs_frps.csv`

---

## Step 4: Run Tests in CDP

### 4.1 Trigger Test Run

1. Navigate to: **CDP Portal → Test Suites → future-grants-perf-tests**
2. Click **"Run Test Suite"**
3. Select environment: `perf-test`
4. Click **"Start Test"**

### 4.2 Monitor Execution

The test will:

1. **Generate session cookies** (10 cookies, ~2 minutes per cookie = ~20 minutes)
2. **Run JMeter tests** (duration depends on case count)
   - 10 concurrent threads
   - Each thread processes cases from CSV until exhausted
   - Maximum duration: 2 hours (7200 seconds)
3. **Generate HTML report** (requires 3GB heap, ~1 minute)
4. **Upload results to S3**

**Expected timeline for 100 cases:**
- Cookie generation: ~20 minutes
- JMeter execution: ~40-60 minutes
- Report generation: ~1 minute
- **Total: ~60-80 minutes**

### 4.3 What Tests Do

Each test iteration performs a complete case workflow:

1. Get case ID by reference
2. Navigate to case details page
3. Submit claim for agreement
4. Complete case workflow steps
5. Submit final claim

**Success criteria:**
- All HTTP requests return 200 OK (or expected status codes)
- No JMeter errors
- HTML report generated successfully

---

## Step 5: View Results

### 5.1 Access Report

After test completion, navigate to:

```
CDP Portal → Test Suites → Test Results → [Your Test Run] → index.html
```

### 5.2 Key Metrics to Check

**Dashboard:**
- **Total Samples:** Should match (case count × requests per case)
- **Error %:** Should be 0% (or very low)
- **Throughput:** Requests per second
- **Response Times:** Average, 90th percentile, 95th percentile

**Response Times Over Time:**
- Check for performance degradation over test duration
- Should remain relatively stable

**Errors (if any):**
- Review error types and counts
- Common errors:
  - 404: Cases not created (seeding issue)
  - 401/403: Cookie expired (test ran > 4 hours)
  - 500: Backend errors (check application logs)

---

## Running Tests Locally

### Prerequisites

- Docker installed
- AWS credentials configured (for S3 uploads)
- LocalStack running (optional, for local S3)
- Entra ID credentials

### Step 1: Update JMeter Configuration for Local Testing

Edit `scenarios/cw-journey-complete.jmx` in JMeter GUI or manually:

**Change these variables:**

| Variable | CDP Value | Local Value |
|----------|-----------|-------------|
| `BASE_URL_2` | `fg-cw-backend.perf-test.cdp-int.defra.cloud` | `ephemeral-protected.api.perf-test.cdp-int.defra.cloud` |
| `PATH_PREFIX` | (empty) | `/fg-cw-backend` |
| `API_KEY` | (empty) | Your Developer API key |

**Result URLs:**
- CDP: `https://fg-cw-backend.perf-test.cdp-int.defra.cloud/cases/ref/...`
- Local: `https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-cw-backend/cases/ref/...`

### Step 2: Build Docker Image

```bash
docker build . -t my-performance-tests
```

### Step 3: Run Tests with LocalStack

**Start LocalStack (if using local S3):**

```bash
docker run -d -p 4566:4566 localstack/localstack

# Create S3 bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-bucket
```

**Run tests:**

```bash
docker run \
  -e S3_ENDPOINT='http://host.docker.internal:4566' \
  -e RESULTS_OUTPUT_S3_PATH='s3://my-bucket' \
  -e AWS_ACCESS_KEY_ID='test' \
  -e AWS_SECRET_ACCESS_KEY='test' \
  -e AWS_SECRET_KEY='test' \
  -e AWS_REGION='eu-west-2' \
  -e ENVIRONMENT='perf-test' \
  -e ENTRA_ID_USERNAME='sa-fgcw.writer@defra.onmicrosoft.com' \
  -e ENTRA_ID_PASSWORD='your-password' \
  -e COOKIE_COUNT=10 \
  my-performance-tests
```

### Step 4: View Local Results

Results are uploaded to LocalStack S3:

```bash
# List results
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-bucket/

# Download report
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-bucket/index.html ./report.html

# Download full report directory
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-bucket/ ./report/ --recursive
```

Open `report/index.html` in a browser.

### Step 5: Revert Configuration for CDP

**IMPORTANT:** After local testing, revert the JMeter configuration:

```bash
git checkout scenarios/cw-journey-complete.jmx
```

Or manually change back:
- `BASE_URL_2` → `fg-cw-backend.perf-test.cdp-int.defra.cloud`
- `PATH_PREFIX` → (empty)
- `API_KEY` → (empty)

---

## Troubleshooting

### Issue: "No report found"

**Cause:** JMeter OutOfMemoryError during report generation

**Solution:** Already fixed with `JVM_ARGS="-Xms1g -Xmx3g"` in entrypoint.sh

**Verify fix:** Check logs for `java.lang.OutOfMemoryError` - should not appear

---

### Issue: "caseId must only contain hexadecimal characters"

**Cause:** Cases don't exist in CW database (seeding failed)

**Check:**
1. Verify hotfix branches deployed to `perf-test`
2. Check GAS logs for seeding completion
3. Check CW MongoDB: `db.cases.countDocuments({})`
4. Check GAS outbox: `db.outbox.countDocuments({ status: "PUBLISHED" })`

**Fix:** Redeploy hotfix branches to trigger fresh seeding

---

### Issue: "Session cookies expired" (401/403 errors)

**Cause:** Test ran longer than 4 hours

**Solution:**
- Reduce `PERF_TEST_COUNT` to fewer applications
- Current limit: 2 hours max test duration + 4 hours cookie expiry = safe for ~200 cases

---

### Issue: "CSV file not found" during cookie generation

**Cause:** Cookie generation script failed

**Check:** Logs for cookie generation errors

**Common causes:**
- Entra ID credentials incorrect
- Chrome/Chromedriver not installed (should be in Dockerfile)
- Network timeout during login

**Fix:** Verify `ENTRA_ID_USERNAME` and `ENTRA_ID_PASSWORD` secrets

---

### Issue: Test processes 0 cases

**Cause:** CSV recycle is `false` and stopThread is `true`, but CSV is empty or has only header

**Check:**
```bash
wc -l data/perf_test_case_refs_frps.csv
# Should show: case count + 1 (header line)
```

**Fix:** Regenerate CSV with correct case count (see Step 1.2)

---

### Issue: Application count in GAS doesn't match PERF_TEST_COUNT

**Cause:** Seeding script logic - it always clears and re-creates (after recent fix)

**Expected behavior:** Should always match `PERF_TEST_COUNT` after deployment

**Check:**
```javascript
db.applications.countDocuments({ clientRef: /^perf-test-/ })
```

**Fix:** If count is wrong, redeploy hotfix branch

---

### Issue: Cases created in CW but tests fail to find them

**Cause:** Case refs in CSV don't match actual case refs created

**Check:**
```javascript
// CW MongoDB - get actual case refs
db.cases.find({}, { caseRef: 1 }).limit(10)

// Compare with CSV
cat data/perf_test_case_refs_frps.csv | head -10
```

**Fix:** Ensure CSV matches the pattern used by seeding script (`perf-test-00000`, `perf-test-00001`, etc.)

---

### Issue: OutOfMemory error still occurs

**Cause:** Test generated too many samples for 3GB heap

**Solution:** Either reduce test count or increase heap further

**Edit entrypoint.sh:**
```bash
export JVM_ARGS="-Xms2g -Xmx4g"  # Increase to 4GB
```

---

### Issue: Tests run but cookies show only 1-2 instead of 10

**Cause:** `COOKIE_COUNT` environment variable not set or entrypoint.sh has wrong default

**Check:** Logs for `"Generating X session cookies..."`

**Fix:** Set `COOKIE_COUNT=10` in CDP secrets or verify entrypoint.sh line 54 has `COOKIE_COUNT=${COOKIE_COUNT:-10}`

---

## Performance Tuning

### Adjusting Concurrency

Edit `scenarios/cw-journey-complete.jmx`:

```xml
<intProp name="ThreadGroup.num_threads">10</intProp>
```

**Guidelines:**
- More threads = higher load, faster completion
- Ensure you have enough cookies (COOKIE_COUNT ≥ thread count)
- Don't exceed backend capacity (start with 10, increase gradually)

### Adjusting Duration

Edit `scenarios/cw-journey-complete.jmx`:

```xml
<longProp name="ThreadGroup.duration">7200</longProp>
```

**Guidelines:**
- 7200 seconds = 2 hours
- Must be less than cookie expiry (4 hours)
- Test stops when CSV exhausted OR duration reached (whichever first)

### Adjusting Ramp-Up Period

Edit `scenarios/cw-journey-complete.jmx`:

```xml
<intProp name="ThreadGroup.ramp_time">10</intProp>
```

**Guidelines:**
- Current: 10 threads start over 10 seconds (1 thread/second)
- Increase for gradual load increase
- Decrease for immediate full load

---

## Files and Their Purpose

| File | Purpose | Must Update? |
|------|---------|--------------|
| `data/perf_test_case_refs_frps.csv` | Case references JMeter will test | ✅ Yes - match PERF_TEST_COUNT |
| `data/session-cookies.csv` | Session cookies (auto-generated) | ❌ No - generated during test |
| `data/perf_test_user_ids.csv` | User IDs (currently unused) | ❌ No - not used by current script |
| `scenarios/cw-journey-complete.jmx` | JMeter test plan | ⚠️ Only for local testing (BASE_URL_2, PATH_PREFIX, API_KEY) |
| `entrypoint.sh` | Test runner script | ❌ No - unless changing memory/cookie count |
| `Dockerfile` | Docker image definition | ❌ No - unless adding dependencies |
| `auth/run/generate-multiple-cookies.sh` | Cookie generation | ❌ No - works automatically |

---

## Quick Reference: Environment Variables

### CDP Test Suite Secrets

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `ENTRA_ID_USERNAME` | ✅ Yes | - | Service account username |
| `ENTRA_ID_PASSWORD` | ✅ Yes | - | Service account password |
| `COOKIE_COUNT` | ❌ No | 10 | Number of cookies to generate |

### Hotfix Deployment Configs (GAS & CW)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PERF_TEST_SEED` | ✅ Yes | `false` | Enable perf test data seeding |
| `PERF_TEST_COUNT` | ⚠️ Conditional | 1000 | Number of applications to create |

**Note:** `PERF_TEST_COUNT` must match case refs CSV count

---

## Support and Further Information

- **CDP Setup Details:** See [CDP-SETUP.md](./CDP-SETUP.md)
- **Performance Test Seeding:** See [docs/perf-test-seeding.md](./docs/perf-test-seeding.md)
- **JMeter Documentation:** https://jmeter.apache.org/usermanual/index.html
- **CDP Portal:** https://portal.cdp-int.defra.cloud

---

## Checklist Before Running Tests

Use this checklist before each test run:

- [ ] **1. Case refs CSV updated** (`data/perf_test_case_refs_frps.csv`)
  - [ ] Count matches desired test scale
  - [ ] Format is `perf-test-00000`, `perf-test-00001`, etc.
  - [ ] Changes committed and pushed

- [ ] **2. Hotfix branches deployed (CW first, then GAS)**
  - [ ] `fg-cw-backend/hotfix/perf-test-seed` deployed to `perf-test` first
  - [ ] CW deployment completed and inbox subscriber running
  - [ ] `fg-gas-backend/hotfix/perf-test-seed` deployed to `perf-test` second
  - [ ] GAS seeding logs show `✅ Performance test data seeding complete!`

- [ ] **3. Environment variables set correctly**
  - [ ] `PERF_TEST_SEED=true` on both GAS and CW
  - [ ] `PERF_TEST_COUNT` matches case refs CSV count
  - [ ] Set on both GAS and CW deployments

- [ ] **4. CDP secrets configured**
  - [ ] `ENTRA_ID_USERNAME` set
  - [ ] `ENTRA_ID_PASSWORD` set
  - [ ] `COOKIE_COUNT=10` (optional)

- [ ] **5. Data verification**
  - [ ] GAS: Applications created (check MongoDB or logs)
  - [ ] CW: Cases exist (check MongoDB or UI)
  - [ ] Case count matches expected

- [ ] **6. JMeter configuration (for CDP)**
  - [ ] `BASE_URL_2` = `fg-cw-backend.perf-test.cdp-int.defra.cloud`
  - [ ] `PATH_PREFIX` = (empty)
  - [ ] `API_KEY` = (empty)

- [ ] **7. Ready to run**
  - [ ] Navigate to CDP Portal → Test Suites → future-grants-perf-tests
  - [ ] Click "Run Test Suite"
  - [ ] Monitor progress in logs

---

**Last Updated:** March 26, 2026
