#!/bin/bash

# Script to create 50 FRPS grant applications for performance testing

# BASE_URL="https://fg-gas-backend.perf-test.cdp-int.defra.cloud/grants/frps-private-beta/applications"
BASE_URL=https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-gas-backend/grants/frps-private-beta/applications

# API authentication parameters
X_API_KEY="mbRqR1ywD475dR9wz5YYQa4vtTz4ojj7"
BEARER_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyIsImtpZCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyJ9.eyJhdWQiOiJhcGk6Ly83NjBlMGM5OS1mODRhLTQ1ZTYtOWQ2MC00NzUwZmI1MDhhZmQiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83NzBhMjQ1MC0wMjI3LTRjNjItOTBjNy00ZTM4NTM3ZjExMDIvIiwiaWF0IjoxNzYzMTMxMTYzLCJuYmYiOjE3NjMxMzExNjMsImV4cCI6MTc2MzEzNjAyNywiYWNyIjoiMSIsImFpbyI6IkFiUUFTLzhhQUFBQUhOV0h2U1h0SUxjMHdLY1ZPS0JUQ3ZZdnR1V1FoeXlmdWVyY241NEdLbGtqK2RpbmkzU3dKR3VTdmNLa2xteEhseHdKWHBqRFNua1ZoVStMOVR6VjZTZkcyMzVLb3ZhakUrTyt6VmkvWkhpYTg3dGdiZVlRU2NTcHhMcEJtNGY5SUVYdjVneXQ3Uk55MVI2akdXWFhyVVRBamRuTmxEcXZLc2JKYUJSd2x0NnR1K09nRWRYZFVSckEzbVBjOWluNTJuU2N1QjdhVnJSMFdPejcwMkdIRVNqTENtVTZnM0dBbEdMcU9odnJqMEE9IiwiYW1yIjpbIm90cCJdLCJhcHBpZCI6Ijc2MGUwYzk5LWY4NGEtNDVlNi05ZDYwLTQ3NTBmYjUwOGFmZCIsImFwcGlkYWNyIjoiMSIsImVtYWlsIjoibml0aW4ubWFsaUBlcXVhbGV4cGVydHMuY29tIiwiaWRwIjoibWFpbCIsImlwYWRkciI6IjIxMi41Ni4xMDcuMTM2IiwibmFtZSI6Im5pdGluLm1hbGkgKEd1ZXN0KSIsIm9pZCI6ImFiMzhmZDdmLTllZjQtNDQzYy05NWQ1LTM4MzUwZGFhNzc2ZCIsInJoIjoiMS5BUXdBVUNRS2R5Y0NZa3lReDA0NFUzOFJBcGtNRG5aSy1PWkZuV0JIVVB0UWl2ME1BT2NNQUEuIiwicm9sZXMiOlsiRkNQLkNhc2V3b3JrLkFkbWluIl0sInNjcCI6ImN3LmJhY2tlbmQiLCJzaWQiOiIwMGFhMDM4OS05MWNmLWEzYzItNTMyZC1jNTJmMjBhYmNkZjgiLCJzdWIiOiJxZVp4NXlFeGxtS1BYTXRBUGRNTTN6dWVjQ2Jqc1FZaXdNTE5HdDlIRGpjIiwidGlkIjoiNzcwYTI0NTAtMDIyNy00YzYyLTkwYzctNGUzODUzN2YxMTAyIiwidW5pcXVlX25hbWUiOiJtYWlsI25pdGluLm1hbGlAZXF1YWxleHBlcnRzLmNvbSIsInV0aSI6IkMyVFFlUTZzTkVPZml1MzZ6OEFWQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfZnRkIjoiN0ZHTWo4aS0zRkdkbnBrZlZsRzFCS1U1dmMtTVJIZmlVcjdVTEk2NG1CVUJaWFZ5YjNCbGQyVnpkQzFrYzIxeiJ9.Xu7FItt7wpbnZvRy5g95zVPTe2jUE1kjKBOAZfqRCSEtLVQPAbHL2N7aNRDVEm22610O01SCrQ6WIlXs0zepx4FzfMA_EwoGDKQ2ShnaFJY0f97a4hCCU4YDiUhQleKyBmCsIVUh_4TdhKL4NEGwFwwGHP-me_XCmOkmfb--jETYzzA2V5j4aZl6MqxkYYnaEAh_hI_FjV8RfpD1_ScM3JNnizW1zgWG-smKqdhc8GdB1Vl464h8JyA_zA32M3_3pZzrksQYlQaX3Ex-eO0mM7uucVAHMq241dnqYUa-_RFQdQPpWb-Z0I2QHJa9XlfyUSaxUVxnIX1FBhV4fpeeXQ"



# echo "Creating 100 FRPS grant applications..."

# for i in $(seq 1 100); do
#     CASE_REF="frps-perf-test-client-ref-$(date +%s)-$i"
#     SBI="SBI$(printf "%03d" $i)"
#     FRN="FIRM$(printf "%04d" $i)"
#     CRN="CUST$(printf "%04d" $i)"
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
#     MOBILE_SUFFIX=$((RANDOM % 999999 + 100000))
    
#     # Generate emails based on names
#     FIRST_LOWER=$(echo "$FIRST_NAME" | tr '[:upper:]' '[:lower:]')
#     LAST_LOWER=$(echo "$LAST_NAME" | tr '[:upper:]' '[:lower:]')
#     BUSINESS_LOWER=$(echo "$BUSINESS_NAME" | sed 's/ //g' | sed 's/Ltd//g' | tr '[:upper:]' '[:lower:]')
    
#     CUSTOMER_EMAIL="${FIRST_LOWER}.${LAST_LOWER}@example.com"
#     BUSINESS_EMAIL="info@${BUSINESS_LOWER}.co.uk"
    
#     echo "Creating application with caseRef: $CASE_REF"
    
#     PAYLOAD="{
#         \"metadata\": {
#             \"clientRef\": \"$CASE_REF\",
#             \"sbi\": \"$SBI\",
#             \"frn\": \"$FRN\",
#             \"crn\": \"$CRN\",
#             \"defraId\": \"$DEFRA_ID\",
#             \"createdAt\": \"2025-03-27T10:34:52.000Z\",
#             \"submittedAt\": \"2025-03-28T11:30:52.000Z\"
#         },
#         \"answers\": {
#             \"applicationValidationRunId\": 123,
#             \"scheme\": \"SFI\",
#             \"year\": 2025,
#             \"hasCheckedLandIsUpToDate\": true,
#             \"applicant\": {
#                 \"business\": {
#                     \"reference\": \"1101313269\",
#                     \"email\": { \"address\": \"$BUSINESS_EMAIL\" },
#                     \"phone\": { \"mobile\": \"0044770090$MOBILE_SUFFIX\" },
#                     \"name\": \"$BUSINESS_NAME\",
#                     \"address\": {
#                         \"line1\": \"$HOUSE_NUM $STREET\",
#                         \"line2\": \"$AREA\",
#                         \"line3\": \"Haute Vienne\",
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
#             \"totalAnnualPaymentPence\": 35150,
#             \"parcels\": [
#                 {
#                     \"sheetId\": \"AB$((1234 + i))\",
#                     \"parcelId\": \"$((10001 + i))\",
#                     \"area\": {
#                         \"unit\": \"ha\",
#                         \"quantity\": 10.0
#                     },
#                     \"actions\": [
#                         {
#                             \"code\": \"CMOR1\",
#                             \"description\": \"Assess moorland and produce a written record\",
#                             \"durationYears\": 3,
#                             \"eligible\": {
#                                 \"unit\": \"ha\",
#                                 \"quantity\": 7.5
#                             },
#                             \"appliedFor\": {
#                                 \"unit\": \"ha\",
#                                 \"quantity\": 7.5
#                             },
#                             \"paymentRates\": {
#                                 \"ratePerUnitPence\": 1060,
#                                 \"agreementLevelAmountPence\": 27200
#                             },
#                             \"annualPaymentPence\": 35150
#                         }
#                     ]
#                 },
#                 {
#                     \"sheetId\": \"DX$((1234 + i))\",
#                     \"parcelId\": \"$((10002 + i))\",
#                     \"area\": {
#                         \"unit\": \"ha\",
#                         \"quantity\": 10.0
#                     },
#                     \"actions\": [
#                         {
#                             \"code\": \"UPL1\",
#                             \"description\": \"Assess moorland and produce a written record\",
#                             \"durationYears\": 3,
#                             \"eligible\": {
#                                 \"unit\": \"ha\",
#                                 \"quantity\": 7.5
#                             },
#                             \"appliedFor\": {
#                                 \"unit\": \"ha\",
#                                 \"quantity\": 7.5
#                             },
#                             \"paymentRates\": {
#                                 \"ratePerUnitPence\": 1060,
#                                 \"agreementLevelAmountPence\": 27200
#                             },
#                             \"annualPaymentPence\": 35150
#                         }
#                     ]
#                 }
#             ],
#             \"actionApplications\": [
#                 {
#                     \"parcelId\": \"$((10001 + i))\",
#                     \"sheetId\": \"AB$((1234 + i))\",
#                     \"code\": \"CMOR1\",
#                     \"appliedFor\": {
#                         \"unit\": \"ha\",
#                         \"quantity\": 7.5
#                     }
#                 },
#                 {
#                     \"parcelId\": \"$((10002 + i))\",
#                     \"sheetId\": \"DX$((1234 + i))\",
#                     \"code\": \"UPL1\",
#                     \"appliedFor\": {
#                         \"unit\": \"ha\",
#                         \"quantity\": 7.5
#                     }
#                 }
#             ],
#             \"payment\": {
#                 \"agreementStartDate\": \"2025-09-01\",
#                 \"agreementEndDate\": \"2026-08-31\",
#                 \"frequency\": \"Monthly\",
#                 \"agreementTotalPence\": 35150,
#                 \"annualTotalPence\": 35150,
#                 \"parcelItems\": {
#                     \"description\": \"Moorland assessment agreement\",
#                     \"annualPaymentPence\": 35150
#                 },
#                 \"agreementLevelItems\": {
#                     \"type\": \"adminFee\",
#                     \"annualPaymentPence\": 0
#                 },
#                 \"payments\": [
#                     {
#                         \"paymentDate\": \"2025-10-01\",
#                         \"totalPaymentPence\": 2929,
#                         \"lineItems\": [
#                             {
#                                 \"description\": \"Monthly moorland assessment payment\",
#                                 \"paymentPence\": 2929
#                             }
#                         ]
#                     }
#                 ]
#             }
#         }
#     }"
    
#     echo "=== PAYLOAD BEING SENT ==="
#     echo "$PAYLOAD" | jq '.' 2>/dev/null || echo "$PAYLOAD"
#     echo "=========================="
    
#     curl --location "$BASE_URL" \
#         --header 'accept: application/json' \
#         --header 'Content-Type: application/json' \
#         --header "x-api-key: $X_API_KEY" \
#         --header "Authorization: Bearer $BEARER_TOKEN" \
#         --data "$PAYLOAD"
    
#     echo
#     echo "---"
# done

# echo "Completed creating 100 FRPS grant applications"

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
CSV_FILE="../test-data/perf_test_case_refs_frps.csv"

echo "$RESPONSE" > "$JSON_FILE"

# Create test-data directory if it doesn't exist
mkdir -p "../test-data"

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