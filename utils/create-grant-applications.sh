#!/bin/bash

# Script to create 50 grant applications for performance testing
# BASE_URL="https://fg-gas-backend.perf-test.cdp-int.defra.cloud/grants/pigs-might-fly/applications"
BASE_URL="https://ephemeral-protected.api.dev.cdp-int.defra.cloud/fg-gas-backend/grants/pigs-might-fly/applications"

# API authentication parameters
X_API_KEY=""
BEARER_TOKEN=""

echo "Creating 50 grant applications..."
for i in $(seq -w 1 5); do
    CLIENT_REF="perf-test-client-ref-$(printf "%03d" $i)"
    
    echo "Creating application with clientRef: $CLIENT_REF"
    
    curl --location "$BASE_URL" \
        --header 'accept: application/json' \
        --header 'Content-Type: application/json' \
        --header "x-api-key: $X_API_KEY" \
        --header "Authorization: Bearer $BEARER_TOKEN" \
        --data "{
            \"metadata\": {
                \"clientRef\": \"$CLIENT_REF\",
                \"sbi\": \"123456789\",
                \"frn\": \"987654321\",
                \"crn\": \"CRN123456\",
                \"defraId\": \"DEFRA123456\",
                \"submittedAt\": \"2000-01-01T12:00:00Z\"
            },
            \"answers\": {
                \"isPigFarmer\": true,
                \"totalPigs\": 100,
                \"whitePigsCount\": 40,
                \"berkshirePigsCount\": 25,
                \"britishLandracePigsCount\": 20,
                \"otherPigsCount\": 15
            }
        }"
    
    echo
    echo "---"
done

echo "Completed creating 50 grant applications"