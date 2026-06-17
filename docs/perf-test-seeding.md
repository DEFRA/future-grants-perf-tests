# Performance Test Data Seeding

## Overview

This document describes the performance test data seeding feature for the fg-cw-backend and fg-gas-backend services. This feature automatically seeds test data when deployed to the perf-test environment.

**Branch**: `hotfix/perf-test-seed` (DO NOT MERGE TO MAIN)

**Environment Variables**:
- `PERF_TEST_SEED=true` - Enables performance test seeding (set in perf-test environment only)
- `PERF_TEST_COUNT=<number>` - Number of applications to create (default: 1000)
  - Examples: `PERF_TEST_COUNT=100` for testing, `PERF_TEST_COUNT=15000` for full load

## Configuration

### Environment Variables

| Variable | Required | Default | Description | Example |
|----------|----------|---------|-------------|---------|
| `PERF_TEST_SEED` | Yes | - | Enables perf test seeding. Only set in perf-test environment. | `true` |
| `PERF_TEST_COUNT` | No | `100` | Number of FRPS test applications to create. | `100`, `1000`, `15000` |
| `PERF_TEST_WMP_COUNT` | No | `100` | Number of WMP test applications to create. | `10`, `100` |

**Setting in CDP**:
1. Go to your service configuration in CDP
2. Add/update environment variables
3. Deploy the service

**Examples**:
- Default: 100 FRPS + 100 WMP applications (no env vars needed)
- Large FRPS run: `PERF_TEST_COUNT=1000` → 1,000 FRPS + 100 WMP applications
- Full load: `PERF_TEST_COUNT=15000` → 15,000 FRPS + 100 WMP applications

## Architecture

### Data Flow

```
GAS Backend                          CW Backend
-----------                          ----------
1. Create N applications      ->    5. Receive CreateNewCaseCommand
   (N = PERF_TEST_COUNT)             6. Create cases in database
2. Generate outbox messages   ->    7. Cases available in UI
3. Outbox subscriber          ->
4. Publish to SNS/SQS
```

### Key Principle: Option B Approach

**We only seed data in GAS, not in CW.** Cases are created automatically via SQS messages, testing the full integration flow.

- ✅ GAS: Create applications using `submitApplicationUseCase` → generates SQS messages
- ✅ CW: Create test users only → cases come from SQS
- ❌ CW: Do NOT create cases directly
- ❌ CW: Do NOT delete workflows (they're configuration, not test data)

## Files Modified

### GAS Backend

- `/src/grants/perf-test-seed.js` - Seeds test applications (count configurable via PERF_TEST_COUNT)
- `/src/grants/index.js` - Calls `seedPerfTestData()` in background after server starts

### CW Backend

- `/src/cases/perf-test-seed.js` - Seeds test users, clears test data (cases/outbox/inbox)
- `/src/cases/index.js` - Calls `seedPerfTestData()` in background after server starts
- `/src/cases/routes/find-case-id-by-ref.route.js` - Test endpoint to get case ID by caseRef (no auth)

## Deployment Process

### Prerequisites

- Both services must be deployed to perf-test environment
- `PERF_TEST_SEED=true` environment variable set in perf-test
- All workflow migrations must be complete and valid

### Step-by-Step Deployment

**Note**: Database clearing is **automatic**. The seed scripts will automatically clear and re-seed if the count doesn't match the target.

#### 1. Deploy CW Backend First

**Why first?** CW must be ready to receive SQS messages before GAS sends them.

Deploy `hotfix/perf-test-seed` branch to perf-test environment.

**Expected logs**:

```
Running migrations
Migrated: "20251114123000-add-frps-private-beta.js"
Migrated: "20251120102600-add-frps-private-beta-users.js"
Migrated: "20251202150006-add-status-themes-to-frps.js"
Migrated: "20260216100000-add-required-roles-to-frps-private-beta.js"
Migrated: "20260217153400-frps-update-agreements-tab-dates-conditional.js"
Migrated: "20260324120000-add-themes-to-frps-task-status-options.js"
Finished running migrations
server started
Starting inbox subscriber
Started polling SQS queue: https://sqs.eu-west-2.amazonaws.com/.../cw__sqs__create_new_case_fifo.fifo
🗑️  Clearing test data collections...
   ✓ Cleared cases, outbox, inbox
⏭️  Perf test data already seeded with 2 test users, skipping
```

**Note**: Seeding runs in **background** after server starts to avoid ECS health check timeouts.

**Verify CW is Ready**:

```javascript
// Check workflow has all themes
const wf = db.workflows.findOne({ code: "frps-private-beta" });
const allStatusOptions = wf.phases
  .flatMap((p) => p.stages)
  .flatMap((s) => s.taskGroups)
  .flatMap((g) => g.tasks)
  .flatMap((t) => t.statusOptions);
print(
  `Total: ${allStatusOptions.length}, With theme: ${allStatusOptions.filter((so) => so.theme !== undefined).length}`,
);
// Should show: Total: 24, With theme: 24

// Check test users exist
db.users.countDocuments({ _id: /^perf-test-user-/ });
// Should return: 2
```

#### 2. Deploy GAS Backend Second

Deploy `hotfix/perf-test-seed` branch to perf-test environment.

**Expected logs**:

```
Running migrations
Finished running migrations
server started
Starting outbox subscriber
🧹 Starting performance test data seeding...
   Target FRPS application count: 1000
   Target WMP application count: 100
⚠️  This will CLEAR ALL DATA in test collections
📝 Creating 1000 FRPS test applications...
   ✓ Created 100/1000 FRPS applications
   ...
   ✓ Created all 1000 FRPS applications
📝 Creating 100 WMP test applications...
   ✓ Created 10/100 WMP applications
   ...
   ✓ Created all 100 WMP applications
✅ Performance test data seeding complete!
   FRPS: 1000 applications (perf-test-00000 to perf-test-00999)
   WMP:  100 applications (wmp-perf-test-00000 to wmp-perf-test-00099)
```

**Note**:
- Seeding runs in **background** after server starts to avoid ECS health check timeouts
- FRPS count: `PERF_TEST_COUNT` environment variable (default: 1000)
- WMP count: `PERF_TEST_WMP_COUNT` environment variable (default: 100)

#### 3. Verify Case Creation in CW

**Check CW logs** for inbox processing (may take 30-60 seconds):

```
Processing message from inbox...
Case created successfully with caseRef: FG-FRPS-...
```

**Verify in database**:

```javascript
db.cases.countDocuments({});
// Should return: PERF_TEST_COUNT (or close to it if still processing)
// Example: 1000 (default), 15000 (if PERF_TEST_COUNT=15000)

db.cases.find({}).limit(3).pretty();
// Shows sample cases
```

## Test Data Created

### GAS Backend

**N FRPS Applications** (N = `PERF_TEST_COUNT`, default 1000):

- Scheme: `frps-private-beta`
- Client refs: `perf-test-00000` to `perf-test-{N-1}` (padded to 5 digits)
  - Example with 1000: `perf-test-00000` to `perf-test-00999`
  - Example with 15000: `perf-test-00000` to `perf-test-14999`
- SBI range: `107000000` to `107000000 + N - 1`
- FRN/CRN range: `1100000000` to `1100000000 + N - 1`

**M WMP Applications** (M = `PERF_TEST_WMP_COUNT`, default 100):

- Scheme: `woodland`
- Client refs: `wmp-perf-test-00000` to `wmp-perf-test-{M-1}` (padded to 5 digits)
  - Example with 100: `wmp-perf-test-00000` to `wmp-perf-test-00099`
- SBI: `106284736` (fixed — must match CRN)
- FRN/CRN: `1102838829` (fixed — SBI/CRN pair must match; CRN also matches `data/agreements-credentials.csv` for OIDC login in `wmp-journey-complete.jmx`)

### CW Backend

**2 Test Users**:

- `perf-test-user-1`: perftest.caseworker@example.com (role: caseworker)
- `perf-test-user-2`: perftest.admin@example.com (role: admin)

**N Cases** (created via SQS from GAS applications):

- Case refs: `FG-FRPS-*` (auto-generated by CW)
- Workflow: `frps-private-beta`
- Status: `APPLICATION_RECEIVED`
- Count matches `PERF_TEST_COUNT`

## Using Test Data in Performance Tests

### Getting Case IDs at Runtime

Performance tests can get case IDs dynamically using the test endpoint:

**Endpoint**: `GET /cases/ref/{caseRef}`

**Example**:
```bash
curl https://fg-cw-backend.perf-test.cdp-int.defra.cloud/cases/ref/perf-test-00000
```

**Response**:
```json
{
  "caseRef": "perf-test-00000",
  "caseId": "69c3cfca1fb0ed134838b6cb"
}
```

**Features**:
- ✅ No authentication required
- ✅ Only works in perf-test environment (PERF_TEST_SEED=true)
- ✅ Returns 404 in other environments for security
- ✅ Returns 404 if case not found

### Performance Test Usage

**JavaScript/Node.js example**:
```javascript
// Loop through all test cases
// Count depends on PERF_TEST_COUNT (default: 1000, can be set to 15000, etc.)
const testCount = 1000; // Adjust to match your PERF_TEST_COUNT

for (let i = 0; i < testCount; i++) {
  const caseRef = `perf-test-${String(i).padStart(5, '0')}`;

  // Get case ID
  const response = await fetch(
    `https://fg-cw-backend.perf-test.cdp-int.defra.cloud/cases/ref/${caseRef}`
  );
  const { caseId } = await response.json();

  // Navigate browser to case
  await browser.goto(
    `https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases/${caseId}`
  );
}
```

**JMeter example**:
1. HTTP Request to get case ID:
   - URL: `https://fg-cw-backend.perf-test.cdp-int.defra.cloud/cases/ref/perf-test-${caseNum}`
   - Extract `caseId` from JSON response
2. Use extracted `caseId` in subsequent requests

**Testing from Local Machine**:

Use the ephemeral gateway with your Developer API key:
```bash
curl --location 'https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-cw-backend/cases/ref/perf-test-00000' \
--header 'x-api-key: YOUR_API_KEY'
```

**Note**: Performance tests running inside CDP can access the backend directly without the ephemeral gateway.

### JMeter Configuration

The JMeter script `scenarios/cw-journey-complete.jmx` is pre-configured to work in both environments.

**For CDP Execution** (default - no changes needed):
- `BASE_URL_2`: `fg-cw-backend.perf-test.cdp-int.defra.cloud`
- `PATH_PREFIX`: (empty)
- `API_KEY`: (empty)
- **Result URL**: `https://fg-cw-backend.perf-test.cdp-int.defra.cloud/cases/ref/perf-test-00000`

**For Local Execution**:
1. Open the JMeter script in JMeter GUI
2. Navigate to: Test Plan > User Defined Variables
3. Update these 3 variables:
   - `BASE_URL_2`: `ephemeral-protected.api.perf-test.cdp-int.defra.cloud`
   - `PATH_PREFIX`: `/fg-cw-backend`
   - `API_KEY`: Your Developer API key from CDP portal
4. Save and run the test
5. **Result URL**: `https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-cw-backend/cases/ref/perf-test-00000`

**How it works**:
- The script reads `caseRef` from CSV file `data/perf_test_case_refs_frps.csv`
- Makes GET request to `${PATH_PREFIX}/cases/ref/${caseRef}` with `x-api-key` header (if API_KEY is set)
- Extracts `caseId` from JSON response and stores as `_id` variable
- All subsequent requests use `${_id}` to access the case

**Where to find the x-api-key header in JMeter GUI**:
- Expand: Thread Group > Get Case ID by Ref > API Key Header
- This HeaderManager sends `x-api-key: ${API_KEY}` (empty if API_KEY variable is empty)

## Troubleshooting

### Issue: "Workflow with code 'frps-private-beta' not found"

**Cause**: Workflow was deleted or migrations didn't run.

**Fix**: Check if workflow exists:

```javascript
db.workflows.findOne({ code: "frps-private-beta" });
```

If null, redeploy CW backend to run migrations.

### Issue: "Invalid WorkflowTask: statusOptions[X].theme is required"

**Cause**: Incomplete workflow - theme migration didn't run.

**Fix**:

1. Delete incomplete workflow and changelog entries:

```javascript
db.workflows.deleteOne({ code: "frps-private-beta" });
db.changelog.deleteMany({ fileName: /frps/ });
```

2. Redeploy CW backend to re-run all migrations including:
   - `20251202150006-add-status-themes-to-frps.js` (stage status themes)
   - `20260324120000-add-themes-to-frps-task-status-options.js` (task statusOptions themes)

### Issue: No Cases Created in CW

**Cause**: SQS messages were consumed or expired before CW was ready.

**Fix**: Redeploy GAS backend - it will automatically clear and re-seed applications, generating fresh SQS messages.

Alternatively, manually trigger re-seed by changing `PERF_TEST_COUNT` temporarily and redeploying.

### Issue: "Perf test data already seeded, skipping"

**Cause**: Idempotent check detected existing test data with matching count (prevents race conditions with multiple pods).

**Behavior**: This is **normal** on subsequent pod restarts. Data only seeds once per deployment.

**To re-seed with different count**:
1. Change `PERF_TEST_COUNT` environment variable in CDP
2. Redeploy - will automatically detect count mismatch and re-seed

**To re-seed with same count**: Deployment will skip seeding. Either:
- Manually clear collections (see troubleshooting), or
- Temporarily change `PERF_TEST_COUNT`, deploy, then change back

### Issue: "ECS deployment circuit breaker: tasks failed to start"

**Cause**: This was an issue in earlier versions where seeding ran during startup and blocked the server from becoming healthy.

**Status**: **FIXED** - Seeding now runs in background after server starts.

**What was happening**:
- Seeding 15,000 applications took 10+ minutes
- ECS health checks timed out waiting for server to be ready
- Pods were killed at ~4,150 applications

**Current behavior**:
- Server starts immediately (pods become healthy)
- Seeding runs in background
- All applications are created successfully

**If you still see this**: You may be on an old version. Ensure you're on the latest hotfix commit.

### Issue: Multiple Pods Running Migrations Simultaneously

**Symptoms**:

```
Could not migrate up 20251114123000-add-frps-private-beta.js: E11000 duplicate key error
```

**Cause**: 3 pods trying to run migrations at the same time.

**Expected Behavior**: This is normal in multi-pod deployments:

- One pod succeeds and creates the workflow
- Other pods fail with duplicate key error but continue running
- All pods end up with the same workflow data

**Not a Problem If**:

- At least one pod shows "Migrated: ..." success logs
- Workflow validation passes (all themes present)
- Pods remain healthy and start successfully

**Is a Problem If**:

- ALL pods crash with validation errors
- Workflow is incomplete (missing themes)
- Follow "Invalid WorkflowTask" fix above

## Race Condition Prevention & Auto-Clearing

Both seed scripts include smart idempotent checks that compare existing count to target count:

**GAS**:

```javascript
const targetCount = parseInt(process.env.PERF_TEST_COUNT || "1000", 10);
const existing = await db
  .collection("applications")
  .countDocuments({ clientRef: /^perf-test-/ });

if (existing === targetCount) {
  logger.info(`⏭️  Perf test data already seeded with ${targetCount} applications, skipping`);
  return;
}

// If count doesn't match (e.g., 100 exists but target is 1000), automatically clear and re-seed
logger.info(`🔄 Found ${existing} applications, target is ${targetCount}. Will clear and re-seed.`);
await clearCollections(db);
await createApplications(targetCount);
```

**CW**:

```javascript
const targetCount = 2; // Number of test users
const existing = await db
  .collection("users")
  .countDocuments({ _id: /^perf-test-user-/ });

if (existing === targetCount) {
  logger.info(`⏭️  Perf test data already seeded with ${targetCount} test users, skipping`);
  return;
}

// Always clears cases/outbox/inbox on every deployment (regardless of user count)
await db.collection("cases").deleteMany({});
await db.collection("outbox").deleteMany({});
await db.collection("inbox").deleteMany({});
```

This ensures:
- ✅ Only skips if count **exactly matches** target (prevents race conditions)
- ✅ Automatically re-seeds if count changes
- ✅ Safe with 3 pods starting simultaneously
- ✅ CW always clears cases to prepare for new SQS messages

## Workflow Migrations

The frps-private-beta workflow requires **6 migrations** to be complete:

1. **20251114123000-add-frps-private-beta.js**
   - Creates basic workflow structure
   - Adds phases, stages, tasks, and statusOptions (WITHOUT themes)

2. **20251120102600-add-frps-private-beta-users.js**
   - Adds user configuration

3. **20251202150006-add-status-themes-to-frps.js**
   - Adds `theme` field to stage statuses (9 statuses)
   - Updates status names for AGREEMENT_DRAFTED and AGREEMENT_OFFERED

4. **20260216100000-add-required-roles-to-frps-private-beta.js**
   - Adds role permissions to workflow

5. **20260217153400-frps-update-agreements-tab-dates-conditional.js**
   - Updates conditional logic for agreement tab dates

6. **20260324120000-add-themes-to-frps-task-status-options.js** ⭐ **CRITICAL**
   - Adds `theme` field to task statusOptions (24 statusOptions across 7 tasks)
   - Required for WorkflowTaskStatusOption schema validation
   - This migration was missing initially and caused validation failures

### Why Two Theme Migrations?

The workflow has two levels of statuses:

1. **Stage Statuses** (9 total): Top-level workflow statuses like "Application Received", "In Review"
   - Updated by migration #3

2. **Task StatusOptions** (24 total): Status options within individual tasks like "Accept", "Request Information"
   - Updated by migration #6

Both require the `theme` field, but they're in different parts of the workflow structure.

## Verification Queries

### Check Workflow Completeness

```javascript
// Check all 6 migrations ran
db.changelog.find({ fileName: /frps/ }).count();
// Should return: 6

// List all frps migrations
db.changelog
  .find({ fileName: /frps/ }, { fileName: 1, appliedAt: 1 })
  .sort({ appliedAt: 1 });

// Check stage status themes (should be 9/9)
const wf = db.workflows.findOne({ code: "frps-private-beta" });
const stageStatuses = wf.phases
  .flatMap((p) => p.stages)
  .flatMap((s) => s.statuses || []);
print(
  `Stage statuses: ${stageStatuses.length}, With theme: ${stageStatuses.filter((s) => s.theme !== undefined).length}`,
);

// Check task statusOptions themes (should be 24/24)
const allStatusOptions = wf.phases
  .flatMap((p) => p.stages)
  .flatMap((s) => s.taskGroups)
  .flatMap((g) => g.tasks)
  .flatMap((t) => t.statusOptions);
print(
  `Task statusOptions: ${allStatusOptions.length}, With theme: ${allStatusOptions.filter((so) => so.theme !== undefined).length}`,
);
```

### Check Test Data

```javascript
// GAS Backend
db.applications.countDocuments({ clientRef: /^perf-test-/ });
// Should return: PERF_TEST_COUNT (default: 1000)

// CW Backend
db.users.countDocuments({ _id: /^perf-test-user-/ });
// Should return: 2

db.cases.countDocuments({});
// Should return: PERF_TEST_COUNT (matches application count)
```

## Important Notes

1. **DO NOT MERGE TO MAIN**: This is test data seeding for perf-test environment only
2. **Service Accounts Preserved**: The seed script only deletes test users matching `/^perf-test-user-/`, keeping service accounts like `sa-fgcw.writer@defra.onmicrosoft.com`
3. **Workflows are Configuration**: Never delete workflows during seeding - they're configuration data like grants
4. **Deploy Order Matters**: Always deploy CW before GAS to ensure inbox subscriber is ready for messages
5. **Idempotent by Design**: Safe to restart pods - seeding only happens once per deployment cycle
6. **Background Seeding**: Seeding runs in background after server starts, so pods become healthy immediately and ECS health checks don't timeout (prevents circuit breaker failures)
7. **Configurable Count**: Use `PERF_TEST_COUNT` environment variable to adjust data volume without code changes

## Version History

- **v1.111.6** (CW): Initial perf-test-seed implementation with theme fix
- **v1.64.5** (GAS): Initial perf-test-seed implementation with submitApplicationUseCase

## Related Files

### CW Backend

- `src/cases/perf-test-seed.js` - Main seeding logic
- `src/cases/index.js` - Integration point
- `src/cases/routes/find-case-id-by-ref.route.js` - Test endpoint to get case ID by caseRef
- `migrations/20251114123000-add-frps-private-beta.js` - Workflow creation
- `migrations/20251202150006-add-status-themes-to-frps.js` - Stage status themes
- `migrations/20260324120000-add-themes-to-frps-task-status-options.js` - Task statusOptions themes
- `src/cases/schemas/task.schema.js` - StatusOption validation (requires theme)

### GAS Backend

- `src/grants/perf-test-seed.js` - Main seeding logic
- `src/grants/index.js` - Integration point
- `src/grants/use-cases/submit-application.use-case.js` - Creates applications properly

## Support

For issues or questions:

- Check CloudWatch logs in AWS Console
- Connect to MongoDB using mongosh for manual inspection
- Review this documentation's troubleshooting section
