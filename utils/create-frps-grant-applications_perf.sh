#!/bin/bash

# Script to create 50 FRPS grant applications for performance testing

BASE_URL=https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-gas-backend/grants/frps-private-beta/applications
# BASE_URL=https://ephemeral-protected.api.test.cdp-int.defra.cloud/fg-gas-backend/grants/frps-private-beta/applications

# API authentication parameters
X_API_KEY="6OatLCfXOsTplxNLv9N80lJYbDmjCEF5" # generate fresh. 
CW_BEARER_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlBjWDk4R1g0MjBUMVg2c0JEa3poUW1xZ3dNVSIsImtpZCI6IlBjWDk4R1g0MjBUMVg2c0JEa3poUW1xZ3dNVSJ9.eyJhdWQiOiJhcGk6Ly83NjBlMGM5OS1mODRhLTQ1ZTYtOWQ2MC00NzUwZmI1MDhhZmQiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83NzBhMjQ1MC0wMjI3LTRjNjItOTBjNy00ZTM4NTM3ZjExMDIvIiwiaWF0IjoxNzY4MjMzMDIwLCJuYmYiOjE3NjgyMzMwMjAsImV4cCI6MTc2ODIzNzA0NSwiYWNyIjoiMSIsImFpbyI6IkFYUUFpLzhhQUFBQU11NG41d24zRHdrOTFyQ1ZWVWpxanAyZUVmZzZMWnZBYUR4ZlBMSzhYSy96azE5T1pTRzd4YzI1b1pZcExlYjZVZ2M1Z1IrYWNuSm9zbmtsNDlLcXExY0t1U1VaZWZZWGVvV2h1d2xqM0lub3E0M015MGZCR1ZzRGp4WEJnYnp6d2ZYZkVwSTBMOW9VWUxQMmlzVGwzUT09IiwiYW1yIjpbInB3ZCJdLCJhcHBpZCI6Ijc2MGUwYzk5LWY4NGEtNDVlNi05ZDYwLTQ3NTBmYjUwOGFmZCIsImFwcGlkYWNyIjoiMSIsImVtYWlsIjoiU0EtRkdDVy5BRE1JTkBkZWZyYS5vbm1pY3Jvc29mdC5jb20iLCJmYW1pbHlfbmFtZSI6IkFETUlOIiwiZ2l2ZW5fbmFtZSI6IlNBLUZHQ1ciLCJpcGFkZHIiOiIyMTIuNTYuMTA3LjEzNiIsIm5hbWUiOiJTQS1GR0NXIEFETUlOIChFcXVhbCBFeHBlcnRzKSIsIm9pZCI6IjI3MWU3M2M0LWM4NjQtNGIxNy1iMWJlLTY4NTcwZDYwYzkwYSIsInJoIjoiMS5BUXdBVUNRS2R5Y0NZa3lReDA0NFUzOFJBcGtNRG5aSy1PWkZuV0JIVVB0UWl2ME1BRFVNQUEuIiwicm9sZXMiOlsiRkNQLkNhc2V3b3JrLkFkbWluIl0sInNjcCI6ImN3LmJhY2tlbmQiLCJzaWQiOiIwMDExMWVlYS1mNjIzLTc5ODItNmFjZS04ZGYwYzdiYzQ1Y2UiLCJzdWIiOiJtU1NoRGNFR1VoS3ZPRmZuR25vQ2FpZ2FON0ZrT3puMlFiZHUwdUFqYTBBIiwidGlkIjoiNzcwYTI0NTAtMDIyNy00YzYyLTkwYzctNGUzODUzN2YxMTAyIiwidW5pcXVlX25hbWUiOiJTQS1GR0NXLkFETUlOQGRlZnJhLm9ubWljcm9zb2Z0LmNvbSIsInVwbiI6IlNBLUZHQ1cuQURNSU5AZGVmcmEub25taWNyb3NvZnQuY29tIiwidXRpIjoiYXJDLU1RY1JHVTJIc0xrWkNySlVBQSIsInZlciI6IjEuMCIsInhtc19mdGQiOiJEQTJ4QTNTZWM2aTJxOGlTYXpsWDJXQ0VMbWY3U1Jia1VkRXI1Q1JLdlcwQmMzZGxaR1Z1WXkxa2MyMXoifQ.avZ85KRT2rnfR5shJ_IEu2kuivyuevipWiClozRA7SNHzJopjcDIsB1APg14McfUGuGS2Uubo_MVScmCB4s0O1a4g0VJztiO3Wdf9ce_Yug8476eebyplH6Kjn29KvzkURrmbvOjffr7SZl7Ujf3R6hsdRke7Cnd-T5k-7c42rubnHfn0LR2Ckua93DW1weN3Q_ajh-vktl9pLYVfb6N7NbzUsypdTcln9eakylL5jgOIME2gkUtyxNqAbJ-p8vMZBbMXc51JihvEO322hlgxevo-EknnNIyxGILDMXtSZOmw8cDX630MjV4aeAcII6fP2HtEJER2YfNVO9lDr65vA"
BEARER_TOKEN="24b8165f-dea5-417e-8216-d9350cdf0d5a" #doesnt change. fixed value
echo "Creating 50 FRPS grant applications..."


# for i in $(seq 1 100); do
#     CASE_REF="case-ref-$(date +%s)-$i"
#     SBI="SBI$(printf "%03d" $i)"
#     FRN="FIRM$(date +%s)$(printf "%04d" $i)$((RANDOM % 1000))"
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
#             \"rulesCalculations\": {
#                 \"id\": $((2000 + i)),
#                 \"message\": \"Application validated successfully\",
#                 \"valid\": true,
#                 \"date\": \"2025-11-21T10:10:43.673Z\"
#             },
#             \"scheme\": \"SFI\",
#             \"applicant\": {
#                 \"business\": {
#                     \"reference\": \"1101313269\",
#                     \"email\": { \"address\": \"$BUSINESS_EMAIL\" },
#                     \"phone\": { \"mobile\": \"0044770090$MOBILE_SUFFIX\" },
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
#                                 \"version\": 1,
#                                 \"durationYears\": 3,
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 4.7575
#                                 }
#                             },
#                             {
#                                 \"code\": \"UPL3\",
#                                 \"version\": 1,
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
#                                 \"version\": 1,
#                                 \"durationYears\": 3,
#                                 \"appliedFor\": {
#                                     \"unit\": \"ha\",
#                                     \"quantity\": 2.1705
#                                 }
#                             },
#                             {
#                                 \"code\": \"UPL1\",
#                                 \"version\": 1,
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
    
#     echo "=== PAYLOAD BEING SENT ==="
#     echo "$PAYLOAD" | jq '.' 2>/dev/null || echo "$PAYLOAD"
#     echo "=========================="
    
#     # Validate JSON before sending
#     if echo "$PAYLOAD" | jq '.' >/dev/null 2>&1; then
#         echo "JSON is valid, sending request..."
#         curl --location "$BASE_URL" \
#             --header 'accept: application/json' \
#             --header 'Content-Type: application/json' \
#             --header "x-api-key: $X_API_KEY" \
#             --header "Authorization: Bearer $BEARER_TOKEN" \
#             --data "$PAYLOAD"
#     else
#         echo "ERROR: JSON is invalid!"
#         echo "$PAYLOAD" | jq '.' 2>&1
#     fi
    
#     echo
#     echo "---"
# done

# echo "Completed creating 50 FRPS grant applications"
# sleep 1m
# API Base URL for cases endpoint (casework backend)
CASEWORK_BASE_URL="https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-cw-backend"

echo "1. Getting all cases from casework backend..."
RESPONSE=$(curl -s --location "${CASEWORK_BASE_URL}/cases" \
    --header 'Accept: application/json' \
    --header 'Accept-Encoding: identity' \
    --header "Authorization: Bearer ${CW_BEARER_TOKEN}" \
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