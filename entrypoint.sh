#!/bin/sh

echo "run_id: $RUN_ID in $ENVIRONMENT"

NOW=$(date +"%Y%m%d-%H%M%S")

if [ -z "${JM_HOME}" ]; then
  JM_HOME=/opt/perftest
fi

JM_SCENARIOS=${JM_HOME}/scenarios
JM_REPORTS=${JM_HOME}/reports
JM_LOGS=${JM_HOME}/logs
JM_DATA=${JM_HOME}/data

mkdir -p ${JM_REPORTS} ${JM_LOGS}


# ============================================
# Generate Session Cookies for JMeter
# ============================================
echo ""
echo "========================================"
echo "Generating session cookies for JMeter"
echo "========================================"

# Check if Entra ID credentials are provided
if [ -z "${ENTRA_ID_USERNAME}" ] || [ -z "${ENTRA_ID_PASSWORD}" ]; then
  echo "ERROR: ENTRA_ID_USERNAME and ENTRA_ID_PASSWORD environment variables are required"
  echo "These should be set from CDP secrets"
  exit 1
fi

# Navigate to auth directory
cd ${JM_HOME}/auth/run

# Create .env file with Entra ID credentials
cat > .env << EOF
ENTRA_ID_USERNAME=${ENTRA_ID_USERNAME}
ENTRA_ID_PASSWORD=${ENTRA_ID_PASSWORD}
APP_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/
EXPECTED_DOMAIN=fg-cw-frontend
COOKIE_NAME=session
OUTPUT_FILE=./artifacts/cw-fe-session.json
CASES_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases
EOF

echo "✓ Entra ID credentials configured"

# Generate session cookies (10 cookies by default)
COOKIE_COUNT=${COOKIE_COUNT:-10}
echo "Generating ${COOKIE_COUNT} session cookies..."

chmod +x generate-multiple-cookies.sh
./generate-multiple-cookies.sh ${COOKIE_COUNT}

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to generate session cookies"
  exit 1
fi

# Return to perftest directory
cd ${JM_HOME}

# Verify cookies were generated
if [ ! -f "${JM_DATA}/session-cookies.csv" ]; then
  echo "ERROR: Session cookies file not found at ${JM_DATA}/session-cookies.csv"
  exit 1
fi

COOKIE_LINE_COUNT=$(wc -l < ${JM_DATA}/session-cookies.csv)
echo "✓ Session cookies generated successfully: ${COOKIE_LINE_COUNT} lines in CSV"
echo "========================================"
echo ""

# ============================================
# Run the test suites in parallel
# ============================================
# Increase JVM heap size to prevent OutOfMemoryError during report generation
export JVM_ARGS="-Xms1g -Xmx3g"

CW_SCENARIO=cw-journey-complete
WMP_SCENARIO=wmp-journey-complete

CW_SCENARIOFILE=${JM_SCENARIOS}/${CW_SCENARIO}.jmx
WMP_SCENARIOFILE=${JM_SCENARIOS}/${WMP_SCENARIO}.jmx

CW_REPORTFILE=${NOW}-perftest-${CW_SCENARIO}-report.csv
WMP_REPORTFILE=${NOW}-perftest-${WMP_SCENARIO}-report.csv

CW_REPORTS=${JM_REPORTS}/cw
WMP_REPORTS=${JM_REPORTS}/wmp

CW_LOGFILE=${JM_LOGS}/perftest-${CW_SCENARIO}.log
WMP_LOGFILE=${JM_LOGS}/perftest-${WMP_SCENARIO}.log

mkdir -p ${CW_REPORTS} ${WMP_REPORTS}

# ============================================
# Validate submit-applications prerequisites
# ============================================
SUBMIT_EXIT=0
SUBMIT_REPORTFILE=""
if [ "${RUN_SUBMIT_APPLICATIONS}" = "true" ]; then
  if [ -z "${GAS_AUTH_TOKEN}" ]; then
    echo "ERROR: GAS_AUTH_TOKEN is required when RUN_SUBMIT_APPLICATIONS=true"
    exit 1
  fi

  SUBMIT_SCENARIO=submit-applications
  SUBMIT_SCENARIOFILE=${JM_SCENARIOS}/${SUBMIT_SCENARIO}.jmx
  SUBMIT_REPORTFILE=${NOW}-perftest-${SUBMIT_SCENARIO}-report.csv
  SUBMIT_REPORTS=${JM_REPORTS}/submit-applications
  SUBMIT_LOGFILE=${JM_LOGS}/perftest-${SUBMIT_SCENARIO}.log

  mkdir -p ${SUBMIT_REPORTS}
fi

# ============================================
# Run all test suites in parallel
# ============================================
echo ""
echo "========================================"
echo "JMeter configuration"
echo "========================================"
echo "  ENVIRONMENT:             ${ENVIRONMENT}"
echo "  USER_COUNT:              ${USER_COUNT}"
echo "  RAMP_UP_PERIOD_SECONDS:  ${RAMP_UP_PERIOD_SECONDS}"
echo "  DURATION_SECONDS:        ${DURATION_SECONDS}"
echo "  DATA dir:                ${JM_DATA}"
echo "  RUN_SUBMIT_APPLICATIONS: ${RUN_SUBMIT_APPLICATIONS}"
echo "========================================"
echo ""

echo "Checking connectivity to CW backend..."
curl -sf -o /dev/null -w "  fg-cw-backend: HTTP %{http_code}\n" https://fg-cw-backend.perf-test.cdp-int.defra.cloud/cases/ref/perf-test-00100 || echo "  fg-cw-backend: UNREACHABLE"
echo ""

echo "Starting cw-journey-complete..."

jmeter -n -t ${CW_SCENARIOFILE} -e -l "${CW_REPORTFILE}" -o ${CW_REPORTS} -j ${CW_LOGFILE} -f -Jenv="${ENVIRONMENT}" -Jcsv_path="${JM_DATA}" -Juser_count="${USER_COUNT}" -Jramp_up_period_seconds="${RAMP_UP_PERIOD_SECONDS}" -Jduration_seconds="${DURATION_SECONDS}" -JBASE_URL_2="fg-cw-backend.perf-test.cdp-int.defra.cloud" &
CW_PID=$!

# WMP temporarily disabled for debugging
WMP_PID=""

# submit-applications temporarily disabled for debugging
SUBMIT_PID=""

wait ${CW_PID}
CW_EXIT=$?
echo "cw-journey-complete exit code: ${CW_EXIT}"

WMP_EXIT=0
if [ -n "${WMP_PID}" ]; then
  wait ${WMP_PID}
  WMP_EXIT=$?
  echo "wmp-journey-complete exit code: ${WMP_EXIT}"
fi

if [ -n "${SUBMIT_PID}" ]; then
  wait ${SUBMIT_PID}
  SUBMIT_EXIT=$?
  echo "submit-applications exit code: ${SUBMIT_EXIT}"
fi

# Publish the results into S3 so they can be displayed in the CDP Portal
if [ -n "$RESULTS_OUTPUT_S3_PATH" ]; then
  if [ -f "${CW_REPORTS}/index.html" ]; then
    aws --endpoint-url=$S3_ENDPOINT s3 rm "$RESULTS_OUTPUT_S3_PATH" --recursive
    aws --endpoint-url=$S3_ENDPOINT s3 cp "$CW_REPORTFILE" "$RESULTS_OUTPUT_S3_PATH/$CW_REPORTFILE"
    aws --endpoint-url=$S3_ENDPOINT s3 cp "${CW_REPORTS}" "$RESULTS_OUTPUT_S3_PATH" --recursive
    if [ $? -eq 0 ]; then
      echo "Test results published to $RESULTS_OUTPUT_S3_PATH"
      echo "  CW report: $RESULTS_OUTPUT_S3_PATH/index.html"
    fi
  else
    echo "No index.html found in CW report directory"
    exit 1
  fi
else
  echo "RESULTS_OUTPUT_S3_PATH is not set"
  exit 1
fi

# Exit non-zero if either test had failures
FAILURES=0
if grep -q ',false,' "${CW_REPORTFILE}" 2>/dev/null; then
  echo "cw-journey-complete CONTAINS FAILURES"
  FAILURES=1
fi
if grep -q ',false,' "${WMP_REPORTFILE}" 2>/dev/null; then
  echo "wmp-journey-complete CONTAINS FAILURES"
  FAILURES=1
fi
if [ "${RUN_SUBMIT_APPLICATIONS}" = "true" ] && grep -q ',false,' "${SUBMIT_REPORTFILE}" 2>/dev/null; then
  echo "submit-applications CONTAINS FAILURES"
  FAILURES=1
fi
if [ ${FAILURES} -eq 1 ]; then
  echo "RESULTS CONTAIN FAILURES, EXITING NON-ZERO"
  exit 1
fi
