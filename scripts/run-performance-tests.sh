#!/bin/bash

# Performance Test Runner Script
# Usage: ./scripts/run-performance-tests.sh [environment] [threads] [ramp_time] [duration]

set -e

# Default values
ENVIRONMENT=${1:-"perf-test"}
THREAD_COUNT=${2:-"10"}
RAMP_TIME=${3:-"5"}
TEST_DURATION=${4:-"300"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting GAS API Performance Tests${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Threads: ${THREAD_COUNT}, Ramp Time: ${RAMP_TIME}s, Duration: ${TEST_DURATION}s${NC}"
echo ""

# Check if JMeter is installed
if ! command -v jmeter &> /dev/null; then
    echo -e "${RED}❌ JMeter is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install JMeter and ensure it's in your PATH${NC}"
    echo -e "${YELLOW}Download from: https://jmeter.apache.org/download_jmeter.cgi${NC}"
    exit 1
fi

# Create results directory
mkdir -p test-results

# Generate timestamp for unique file names
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Check for required credentials
if [ -z "$X_API_KEY" ]; then
    echo -e "${RED}❌ X_API_KEY environment variable is required${NC}"
    echo -e "${YELLOW}Set it with: export X_API_KEY=\"your-api-key\"${NC}"
    exit 1
fi

if [ -z "$AUTHORIZATION_TOKEN" ]; then
    echo -e "${RED}❌ AUTHORIZATION_TOKEN environment variable is required${NC}"
    echo -e "${YELLOW}Set it with: export AUTHORIZATION_TOKEN=\"your-auth-token\"${NC}"
    exit 1
fi

# Base URL based on environment (local uses ephemeral URLs)
case $ENVIRONMENT in
    "perf-test")
        BASE_URL="https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud"
        ;;
    "dev")
        BASE_URL="https://ephemeral-protected.api.dev.cdp-int.defra.cloud"
        ;;
    "test")
        BASE_URL="https://ephemeral-protected.api.test.cdp-int.defra.cloud"
        ;;
    *)
        echo -e "${RED}❌ Unknown environment: $ENVIRONMENT${NC}"
        echo -e "${YELLOW}Supported environments: perf-test, dev, test${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ JMeter found: $(jmeter --version | head -1)${NC}"
echo -e "${GREEN}✅ Base URL: ${BASE_URL}${NC}"
echo ""

# Run the performance test
echo -e "${BLUE}🏃 Running GAS API Performance Tests...${NC}"

jmeter -n \
    -t scenarios/GAS_API_Test.jmx \
    -l test-results/gas_api_results_${TIMESTAMP}.jtl \
    -e -o test-results/html_report_${TIMESTAMP} \
    -JX_API_KEY="${X_API_KEY}" \
    -JAUTHORIZATION_TOKEN="${AUTHORIZATION_TOKEN}" \
    -Japi.domain="ephemeral-protected.api.${ENVIRONMENT}.cdp-int.defra.cloud" \
    -Japi.path="/fg-gas-backend" \
    -Jenv="${ENVIRONMENT}"

# Check if test completed successfully
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Performance tests completed successfully!${NC}"
else
    echo -e "${YELLOW}⚠️ Performance tests completed with some issues${NC}"
fi

# Generate summary
echo ""
echo -e "${BLUE}📊 Test Results Summary${NC}"
echo "========================"

RESULT_FILE="test-results/gas_api_results_${TIMESTAMP}.jtl"

if [ -f "$RESULT_FILE" ]; then
    TOTAL_SAMPLES=$(awk -F',' 'END {print NR-1}' "$RESULT_FILE")
    FAILED_SAMPLES=$(awk -F',' '$8=="false" {count++} END {print count+0}' "$RESULT_FILE")
    SUCCESS_RATE=$(awk -F',' 'BEGIN{total=0; success=0} NR>1{total++; if($8=="true") success++} END{if(total>0) printf "%.2f", (success/total)*100; else print "0"}' "$RESULT_FILE")
    AVG_RESPONSE_TIME=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if(count>0) printf "%.0f", sum/count; else print "0"}' "$RESULT_FILE")
    
    echo "Environment: $ENVIRONMENT"
    echo "Total Samples: $TOTAL_SAMPLES"
    echo "Failed Samples: $FAILED_SAMPLES"
    echo "Success Rate: ${SUCCESS_RATE}%"
    echo "Average Response Time: ${AVG_RESPONSE_TIME}ms"
    echo ""
    
    # Show HTML report location
    echo -e "${GREEN}📈 HTML Report generated at:${NC}"
    echo "   file://$(pwd)/test-results/html_report_${TIMESTAMP}/index.html"
    echo ""
    
    # Determine test status
    if [ "$FAILED_SAMPLES" -eq "0" ]; then
        echo -e "${GREEN}✅ All tests passed successfully!${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️ Some tests failed. Check the HTML report for details.${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Could not find results file: $RESULT_FILE${NC}"
    exit 1
fi