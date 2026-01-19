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

SCENARIOFILE=${JM_SCENARIOS}/${TEST_SCENARIO}.jmx
REPORTFILE=${NOW}-perftest-${TEST_SCENARIO}-report.csv
LOGFILE=${JM_LOGS}/perftest-${TEST_SCENARIO}.log

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

# Start chromedriver in background (if running in Docker/Alpine)
if [ -f "/usr/bin/chromedriver" ]; then
  echo "Starting chromedriver in background..."
  /usr/bin/chromedriver --port=4444 --allowed-ips="" > /tmp/chromedriver.log 2>&1 &
  CHROMEDRIVER_PID=$!
  echo "Chromedriver started with PID: $CHROMEDRIVER_PID"
  sleep 2  # Give chromedriver time to start
fi

chmod +x generate-multiple-cookies.sh
./generate-multiple-cookies.sh ${COOKIE_COUNT}
COOKIE_RESULT=$?

# Stop chromedriver if we started it
if [ -n "$CHROMEDRIVER_PID" ]; then
  echo "Stopping chromedriver (PID: $CHROMEDRIVER_PID)..."
  kill $CHROMEDRIVER_PID 2>/dev/null || true
fi

if [ $COOKIE_RESULT -ne 0 ]; then
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
# Run the test suite
# ============================================
jmeter -n -t ${SCENARIOFILE} -e -l "${REPORTFILE}" -o ${JM_REPORTS} -j ${LOGFILE} -f -Jenv="${ENVIRONMENT}" -Jcsv_path="${JM_DATA}" -Juser_count="${USER_COUNT}" -Jramp_up_period_seconds="${RAMP_UP_PERIOD_SECONDS}" -Jduration_seconds="${DURATION_SECONDS}"

# Publish the results into S3 so they can be displayed in the CDP Portal
if [ -n "$RESULTS_OUTPUT_S3_PATH" ]; then
  # Copy the CSV report file and the generated report files to the S3 bucket
   if [ -f "$JM_REPORTS/index.html" ]; then
      aws --endpoint-url=$S3_ENDPOINT s3 cp "$REPORTFILE" "$RESULTS_OUTPUT_S3_PATH/$REPORTFILE"
      aws --endpoint-url=$S3_ENDPOINT s3 cp "$JM_REPORTS" "$RESULTS_OUTPUT_S3_PATH" --recursive
      if [ $? -eq 0 ]; then
        echo "CSV report file and test results published to $RESULTS_OUTPUT_S3_PATH"
      fi
   else
      echo "$JM_REPORTS/index.html is not found"
      exit 1
   fi
else
   echo "RESULTS_OUTPUT_S3_PATH is not set"
   exit 1
fi

# exit non-zero if failures reported
if grep -q ',false,' ${REPORTFILE}; then
    echo "RESULTS CONTAIN FAILURES, EXITING NON-ZERO"
    exit 1
fi
