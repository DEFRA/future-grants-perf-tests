# Performance Test Data Seeding

## Overview

This document describes the performance test data seeding feature for the fg-cw-backend and fg-gas-backend services. This feature automatically seeds test data when deployed to the perf-test environment.

**Branch**: `hotfix/perf-test-seed` (DO NOT MERGE TO MAIN)

**Environment Variable**: `PERF_TEST_SEED=true` (set in perf-test environment only)

## Architecture

### Data Flow

```
GAS Backend                          CW Backend
-----------                          ----------
1. Create 100 applications    ->    5. Receive CreateNewCaseCommand
2. Generate outbox messages   ->    6. Create cases in database
3. Outbox subscriber          ->    7. Cases available in UI
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

- `/src/grants/perf-test-seed.js` - Seeds 100 test applications
- `/src/grants/index.js` - Calls `seedPerfTestData()` after migrations

### CW Backend

- `/src/cases/perf-test-seed.js` - Seeds test users, clears test data
- `/src/cases/index.js` - Calls `seedPerfTestData()` after migrations

## Deployment Process

### Prerequisites

- Both services must be deployed to perf-test environment
- `PERF_TEST_SEED=true` environment variable set in perf-test
- All workflow migrations must be complete and valid

### Step-by-Step Deployment

#### 1. Clean Up Existing Data (First Time or Re-seed)

**CW Database Cleanup** (mongosh connected to fg-cw-backend):

```javascript
db.cases.deleteMany({});
db.users.deleteMany({ _id: /^perf-test-user-/ });
db.outbox.deleteMany({});
db.inbox.deleteMany({});
```

**GAS Database Cleanup** (mongosh connected to fg-gas-backend):

```javascript
db.applications.deleteMany({});
db.application_series.deleteMany({});
db.outbox.deleteMany({});
db.inbox.deleteMany({});
```

#### 2. Deploy CW Backend First

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
🧹 Starting performance test data seeding...
   ✓ Created 2 test users
✅ Performance test data seeding complete!
Starting inbox subscriber
Started polling SQS queue: https://sqs.eu-west-2.amazonaws.com/.../cw__sqs__create_new_case_fifo.fifo
server started
```

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

#### 3. Deploy GAS Backend Second

Deploy `hotfix/perf-test-seed` branch to perf-test environment.

**Expected logs**:

```
Running migrations
Finished running migrations
🧹 Starting performance test data seeding...
📝 Creating 100 test applications...
   ✓ Created 10/100 applications
   ✓ Created 20/100 applications
   ✓ Created 30/100 applications
   ✓ Created 40/100 applications
   ✓ Created 50/100 applications
   ✓ Created 60/100 applications
   ✓ Created 70/100 applications
   ✓ Created 80/100 applications
   ✓ Created 90/100 applications
   ✓ Created 100/100 applications
✅ Performance test data seeding complete!
   Total applications: 100
   Client refs: perf-test-000 to perf-test-099
```

#### 4. Verify Case Creation in CW

**Check CW logs** for inbox processing (may take 30-60 seconds):

```
Processing message from inbox...
Case created successfully with caseRef: FG-FRPS-...
```

**Verify in database**:

```javascript
db.cases.countDocuments({});
// Should return: 100 (or close to it if still processing)

db.cases.find({}).limit(3).pretty();
// Shows sample cases
```

## Test Data Created

### GAS Backend

**100 Applications**:

- Scheme: `frps-private-beta`
- Client refs: `perf-test-000` to `perf-test-099`
- SBI range: `107000000` to `107000099`
- FRN/CRN range: `1100000000` to `1100000099`

### CW Backend

**2 Test Users**:

- `perf-test-user-1`: perftest.caseworker@example.com (role: caseworker)
- `perf-test-user-2`: perftest.admin@example.com (role: admin)

**100 Cases** (created via SQS):

- Case refs: `FG-FRPS-*` (auto-generated)
- Workflow: `frps-private-beta`
- Status: `APPLICATION_RECEIVED`

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

**Fix**: Clear GAS database and redeploy GAS to generate fresh applications:

```javascript
// In GAS database
db.applications.deleteMany({});
db.application_series.deleteMany({});
db.outbox.deleteMany({});
db.inbox.deleteMany({});
```

Then redeploy GAS backend.

### Issue: "Perf test data already seeded, skipping"

**Cause**: Idempotent check detected existing test data (prevents race conditions with multiple pods).

**Behavior**: This is **normal** on subsequent pod restarts. Data only seeds once per deployment.

**To re-seed**: Clear the database collections (see Step 1) and redeploy.

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

## Race Condition Prevention

Both seed scripts include idempotent checks to prevent duplicate seeding:

**GAS**:

```javascript
const existing = await db
  .collection("applications")
  .countDocuments({ clientRef: /^perf-test-/ });
if (existing > 0) {
  logger.info("⏭️  Perf test data already seeded, skipping");
  return;
}
```

**CW**:

```javascript
const existing = await db
  .collection("users")
  .countDocuments({ _id: /^perf-test-user-/ });
if (existing > 0) {
  logger.info("⏭️  Perf test data already seeded, skipping");
  return;
}
```

This ensures that even with 3 pods starting simultaneously, seeding only happens once.

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
// Should return: 100

// CW Backend
db.users.countDocuments({ _id: /^perf-test-user-/ });
// Should return: 2

db.cases.countDocuments({});
// Should return: 100
```

## Important Notes

1. **DO NOT MERGE TO MAIN**: This is test data seeding for perf-test environment only
2. **Service Accounts Preserved**: The seed script only deletes test users matching `/^perf-test-user-/`, keeping service accounts like `sa-fgcw.writer@defra.onmicrosoft.com`
3. **Workflows are Configuration**: Never delete workflows during seeding - they're configuration data like grants
4. **Deploy Order Matters**: Always deploy CW before GAS to ensure inbox subscriber is ready for messages
5. **Idempotent by Design**: Safe to restart pods - seeding only happens once per deployment cycle

## Version History

- **v1.111.6** (CW): Initial perf-test-seed implementation with theme fix
- **v1.64.5** (GAS): Initial perf-test-seed implementation with submitApplicationUseCase

## Related Files

### CW Backend

- `src/cases/perf-test-seed.js` - Main seeding logic
- `src/cases/index.js` - Integration point
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
