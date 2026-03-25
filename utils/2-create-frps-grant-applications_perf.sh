#!/bin/bash

# Script to create 50 FRPS grant applications for performance testing

BASE_URL=https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-gas-backend/grants/frps-private-beta/applications
# BASE_URL=https://ephemeral-protected.api.test.cdp-int.defra.cloud/fg-gas-backend/grants/frps-private-beta/applications

# API authentication parameters
# //copy from .env
X_API_KEY=wzRP3iTOrNoCMpWgW0H5xaUAdcQ5GsDg
BEARER_TOKEN=99731eaa-43e6-44fe-a18c-25385c1a3a93

echo "Creating 1000 FRPS grant applications..."


# for i in $(seq 1 2); do
#     CASE_REF="case-ref-$(date +%s)-$i"
#     SBI="$((100000000 + i))"
#     FRN="$((1000000000 + i))"
#     CRN="$((1100000000 + i))"
#     DEFRA_ID="DEFRA$(printf "%04d" $i)"
    
#     # Generate random data for each application
#     FIRST_NAMES=("Alice" "Bob" "Charlie" "Diana" "Edward" "Fiona" "George" "Hannah" "Ian" "Julia")
#     LAST_NAMES=("Smith" "Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Davis" "Rodriguez" "Martinez")
#     TITLES=("mr" "mrs" "miss" "ms" "dr")
#     BUSINESS_NAMES=("Farming Solutions Ltd" "Agricultural Services Ltd" "Green Fields Ltd" "Rural Enterprises Ltd" "Farm Management Ltd")
#     STREETS=("High Street" "Church Lane" "Mill Road" "Oak Avenue" "Elm Grove" "Meadow View" "Farm Road" "Village Green" "Manor Drive" "Chapel Street")
#     AREAS=("Mulberry crescent" "Rose Gardens" "Willow Park" "Cedar Close" "Pine View" "Birch Way" "Holly Drive" "Ivy Court" "Maple Close" "Ash Lane")
#     TOWNS=("Birmingham" "Manchester" "Leeds" "Sheffield" "Bristol" "Liverpool" "Newcastle" "Nottingham" "Southampton" "Portsmouth")
#     CITIES=("London" "Birmingham" "Leeds" "Glasgow" "Sheffield" "Bradford" "Liverpool" "Edinburgh" "Manchester" "Bristol")
#     POSTCODES=("B1 1AA" "M1 1AA" "LS1 1AA" "S1 1AA" "BS1 1AA" "L1 1AA" "NE1 1AA" "NG1 1AA" "SO14 1AA" "PO1 1AA")
    
#     FIRST_NAME=${FIRST_NAMES[$((RANDOM % ${#FIRST_NAMES[@]}))]}
#     LAST_NAME=${LAST_NAMES[$((RANDOM % ${#LAST_NAMES[@]}))]}
#     TITLE=${TITLES[$((RANDOM % ${#TITLES[@]}))]}
#     BUSINESS_NAME=${BUSINESS_NAMES[$((RANDOM % ${#BUSINESS_NAMES[@]}))]}
#     STREET=${STREETS[$((RANDOM % ${#STREETS[@]}))]}
#     AREA=${AREAS[$((RANDOM % ${#AREAS[@]}))]}
#     TOWN=${TOWNS[$((RANDOM % ${#TOWNS[@]}))]}
#     CITY=${CITIES[$((RANDOM % ${#CITIES[@]}))]}
#     POSTCODE=${POSTCODES[$((RANDOM % ${#POSTCODES[@]}))]}
    
#     # Generate random numbers for addresses and phones
#     HOUSE_NUM=$((RANDOM % 999 + 1))
#     PHONE_SUFFIX=$((RANDOM % 999999 + 100000))
    
#     # Generate emails based on names
#     FIRST_LOWER=$(echo "$FIRST_NAME" | tr '[:upper:]' '[:lower:]')
#     LAST_LOWER=$(echo "$LAST_NAME" | tr '[:upper:]' '[:lower:]')
#     BUSINESS_LOWER=$(echo "$BUSINESS_NAME" | sed 's/ //g' | sed 's/Ltd//g' | tr '[:upper:]' '[:lower:]')
    
#     CUSTOMER_EMAIL="${FIRST_LOWER}.${LAST_LOWER}@example.com"
#     BUSINESS_EMAIL="info@${BUSINESS_LOWER}.co.uk"

#     # Generate timestamps - createdAt is yesterday, submittedAt is today
#     CREATED_AT=$(date -u -v-1d +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || date -u -d "yesterday" +"%Y-%m-%dT%H:%M:%S.000Z")
#     SUBMITTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

#     echo "Creating application with caseRef: $CASE_REF"
    
#     PAYLOAD="{
#         \"metadata\": {
#             \"clientRef\": \"$CASE_REF\",
#             \"sbi\": \"$SBI\",
#             \"frn\": \"$FRN\",
#             \"crn\": \"$CRN\",
#             \"defraId\": \"$DEFRA_ID\",
#             \"createdAt\": \"$CREATED_AT\",
#             \"submittedAt\": \"$SUBMITTED_AT\"
#         },
#         \"answers\": {
#             \"rulesCalculations\": {
#                 \"id\": $((2000 + i)),
#                 \"message\": \"Application validated successfully\",
#                 \"valid\": true,
#                 \"date\": \"$SUBMITTED_AT\"
#             },
#             \"scheme\": \"SFI\",
#             \"applicant\": {
#                 \"business\": {
#                     \"reference\": \"1101313269\",
#                     \"email\": \"$BUSINESS_EMAIL\",
#                     \"phone\": \"0770090$PHONE_SUFFIX\",
#                     \"name\": \"$BUSINESS_NAME\",
#                     \"address\": {
#                         \"line1\": \"$HOUSE_NUM $STREET\",
#                         \"line2\": \"$AREA\",
#                         \"line3\": null,
#                         \"line4\": null,
#                         \"line5\": null,
#                         \"street\": \"$TOWN\",
#                         \"city\": \"$CITY\",
#                         \"postalCode\": \"$POSTCODE\"
#                     }
#                 },
#                 \"customer\": {
#                     \"name\": {
#                         \"title\": \"$TITLE\",
#                         \"first\": \"$FIRST_NAME\",
#                         \"middle\": null,
#                         \"last\": \"$LAST_NAME\"
#                     }
#                 }
#             },
#             \"totalAnnualPaymentPence\": 70284,
#             \"application\": {
#                 \"parcel\": [
#                     {
#                         \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
#                         \"parcelId\": \"$((7555 + i))\",
#                         \"area\": {
#                             \"unit\": \"ha\",
#                             \"quantity\": 5.2182
#                         },
#                         \"actions\": [
#                             {
#                                 \"code\": \"CMOR1\",
#                                 \"version\": \"1\",
#                                 \"durationYears\": 3,
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 4.7575
#                                 }
#                             },
#                             {
#                                 \"code\": \"UPL3\",
#                                 \"version\": \"1\",
#                                 \"durationYears\": 3,
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 4.7575
#                                 }
#                             }
#                         ]
#                     },
#                     {
#                         \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
#                         \"parcelId\": \"$((9194 + i))\",
#                         \"area\": {
#                             \"unit\": \"ha\",
#                             \"quantity\": 2.1703
#                         },
#                         \"actions\": [
#                             {
#                                 \"code\": \"CMOR1\",
#                                 \"version\": \"1\",
#                                 \"durationYears\": 3,
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 2.1705
#                                 }
#                             },
#                             {
#                                 \"code\": \"UPL1\",
#                                 \"version\": \"1\",
#                                 \"durationYears\": 3,
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 2.1705
#                                 }
#                             }
#                         ]
#                     }
#                 ],
#                 \"agreement\": []
#             },
#             \"payments\": {
#                 \"parcel\": [
#                     {
#                         \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
#                         \"parcelId\": \"$((7555 + i))\",
#                         \"area\": {
#                             \"unit\": \"ha\",
#                             \"quantity\": 5.2182
#                         },
#                         \"actions\": [
#                             {
#                                 \"code\": \"CMOR1\",
#                                 \"description\": \"Assess moorland and produce a written record\",
#                                 \"durationYears\": 3,
#                                 \"paymentRates\": 1060,
#                                 \"annualPaymentPence\": 5042,
#                                 \"eligible\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 4.7575
#                                 },
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 4.7575
#                                 }
#                             },
#                             {
#                                 \"code\": \"UPL3\",
#                                 \"description\": \"Limited livestock grazing on moorland\",
#                                 \"durationYears\": 3,
#                                 \"paymentRates\": 6600,
#                                 \"annualPaymentPence\": 31399,
#                                 \"eligible\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 4.7575
#                                 },
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 4.7575
#                                 }
#                             }
#                         ]
#                     },
#                     {
#                         \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
#                         \"parcelId\": \"$((9194 + i))\",
#                         \"area\": {
#                             \"unit\": \"ha\",
#                             \"quantity\": 2.1703
#                         },
#                         \"actions\": [
#                             {
#                                 \"code\": \"CMOR1\",
#                                 \"description\": \"Assess moorland and produce a written record\",
#                                 \"durationYears\": 3,
#                                 \"paymentRates\": 1060,
#                                 \"annualPaymentPence\": 2300,
#                                 \"eligible\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 2.1705
#                                 },
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 2.1705
#                                 }
#                             },
#                             {
#                                 \"code\": \"UPL1\",
#                                 \"description\": \"Moderate livestock grazing on moorland\",
#                                 \"durationYears\": 3,
#                                 \"paymentRates\": 2000,
#                                 \"annualPaymentPence\": 4341,
#                                 \"eligible\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 2.1705
#                                 },
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 2.1705
#                                 }
#                             }
#                         ]
#                     }
#                 ],
#                 \"agreement\": [
#                     {
#                         \"code\": \"CMOR1\",
#                         \"description\": \"Assess moorland and produce a written record\",
#                         \"durationYears\": 3,
#                         \"paymentRates\": 27200,
#                         \"annualPaymentPence\": 27200
#                     }
#                 ]
#             }
#         }
#     }"
    
#     # echo "=== PAYLOAD BEING SENT ==="
#     # echo "$PAYLOAD" | jq '.' 2>/dev/null || echo "$PAYLOAD"
#     # echo "=========================="
#     # sleep 2s
#     # Validate JSON before sending
#     if echo "$PAYLOAD" | jq '.' >/dev/null 2>&1; then
#         echo "JSON is valid, sending request..."
#         RESPONSE=$(curl -s -w "\n%{http_code}" --location "$BASE_URL" \
#             --header 'accept: application/json' \
#             --header 'Content-Type: application/json' \
#             --header "x-api-key: $X_API_KEY" \
#             --header "Authorization: Bearer $BEARER_TOKEN" \
#             --data "$PAYLOAD")

#         HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
#         BODY=$(echo "$RESPONSE" | sed '$d')

#         echo "=== HTTP STATUS CODE: $HTTP_CODE ==="
#         echo "=== RESPONSE BODY ==="
#         echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
#         echo "===================="
#     else
#         echo "ERROR: JSON is invalid!"
#         echo "$PAYLOAD" | jq '.' 2>&1
#     fi
    
#     echo
#     echo "---"
# done

echo "Completed creating 50 FRPS grant applications"
sleep 1m
# API Base URL for cases endpoint (casework backend)
CASEWORK_BASE_URL="https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-cw-backend"

echo "1. Getting all cases from casework backend..."
RESPONSE=$(curl -s --location "${CASEWORK_BASE_URL}/cases" \
    --header 'Accept: application/json' \
    --header 'Accept-Encoding: identity' \
    --header "Authorization: Bearer ${BEARER_TOKEN}" \
    --header "x-api-key: ${X_API_KEY}")

# Store response in JSON file with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
JSON_FILE="cases_response_${TIMESTAMP}.json"
CSV_FILE="../data/perf_test_case_refs_frps.csv"

echo "$RESPONSE" > "$JSON_FILE"

# Create data directory if it doesn't exist
mkdir -p "../data"

# Parse JSON and create CSV file with caseRef,_id format
echo "caseRef,_id" > "$CSV_FILE"
echo "$RESPONSE" | jq -r '.[] | "\(.caseRef),\(._id)"' >> "$CSV_FILE" 2>/dev/null

echo "Cases JSON response saved to: $JSON_FILE"
echo "Cases CSV file saved to: $CSV_FILE"
echo "Response preview: $(echo "$RESPONSE" | head -c 200)..."
echo "Number of cases found: $(echo "$RESPONSE" | jq '. | length' 2>/dev/null || echo "Could not parse JSON")"

# Show first few lines of CSV
echo ""
echo "CSV preview:"
head -5 "$CSV_FILE" 2>/dev/null || echo "Could not generate CSV preview"
echo ""