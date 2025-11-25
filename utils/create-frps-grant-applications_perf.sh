#!/bin/bash

# Script to create 50 FRPS grant applications for performance testing

# BASE_URL="https://fg-gas-backend.perf-test.cdp-int.defra.cloud/grants/frps-private-beta/applications"
BASE_URL=https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-gas-backend/grants/frps-private-beta/applications
# API authentication parameters
X_API_KEY="GampQDti0qr544kUczNhC6aD4O25k5Uw"
BEARER_TOKEN="24b8165f-dea5-417e-8216-d9350cdf0d5a"
echo "Creating 50 FRPS grant applications..."

# X_API_KEY="5E85pOvnqROHsNbX3NYTWorO5DxK9QFw"
# BEARER_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyIsImtpZCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyJ9.eyJhdWQiOiJhcGk6Ly83NjBlMGM5OS1mODRhLTQ1ZTYtOWQ2MC00NzUwZmI1MDhhZmQiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83NzBhMjQ1MC0wMjI3LTRjNjItOTBjNy00ZTM4NTM3ZjExMDIvIiwiaWF0IjoxNzYzNTUyNjY5LCJuYmYiOjE3NjM1NTI2NjksImV4cCI6MTc2MzU1Nzg3MiwiYWNyIjoiMSIsImFpbyI6IkFiUUFTLzhhQUFBQUJ3RVB5R1o5amdjTkRUTHVEYnpJZXRzcXFTWGJFVjFxdmpwVStHdGJwcEJkbit1dU5rY1poTlZMTjhlTXg5MjM2SnVvMGR0TTYvUEhIOWJEdVNyajRXdkJ4RlFZOGtsZzE5aDZ6aGJRVFd2R3diSmsxZVZiNmpzUEUyVjgwMGtsbERHNTkwRjJMZFRKVktxak5jMk5BeFozd3JOYno2NEgwSENDNWF4UTZzRW1LWUxFdnZpZU95d0xkVUtqWHZmUUwzUitQYVZNZFRERjhwWE04Rjc5MHQ1RVVzdzRIL3h2ajZSV2dZbDdMZWs9IiwiYW1yIjpbIm90cCJdLCJhcHBpZCI6Ijc2MGUwYzk5LWY4NGEtNDVlNi05ZDYwLTQ3NTBmYjUwOGFmZCIsImFwcGlkYWNyIjoiMSIsImVtYWlsIjoibml0aW4ubWFsaUBlcXVhbGV4cGVydHMuY29tIiwiaWRwIjoibWFpbCIsImlwYWRkciI6IjIxMi41Ni4xMDcuMTM2IiwibmFtZSI6Im5pdGluLm1hbGkgKEd1ZXN0KSIsIm9pZCI6ImFiMzhmZDdmLTllZjQtNDQzYy05NWQ1LTM4MzUwZGFhNzc2ZCIsInJoIjoiMS5BUXdBVUNRS2R5Y0NZa3lReDA0NFUzOFJBcGtNRG5aSy1PWkZuV0JIVVB0UWl2ME1BT2NNQUEuIiwicm9sZXMiOlsiRkNQLkNhc2V3b3JrLkFkbWluIl0sInNjcCI6ImN3LmJhY2tlbmQiLCJzaWQiOiIwMGFhYzZkOS0xOTU0LWY1MzEtNDYxZC02NWU4ODBiN2FlZDMiLCJzdWIiOiJxZVp4NXlFeGxtS1BYTXRBUGRNTTN6dWVjQ2Jqc1FZaXdNTE5HdDlIRGpjIiwidGlkIjoiNzcwYTI0NTAtMDIyNy00YzYyLTkwYzctNGUzODUzN2YxMTAyIiwidW5pcXVlX25hbWUiOiJtYWlsI25pdGluLm1hbGlAZXF1YWxleHBlcnRzLmNvbSIsInV0aSI6Ikh0U1ZjRlozYlVxRDZkOWhadndHQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfZnRkIjoia0h0cHFONmV4MEN0aDNjRTVhVkxMeU8tek0zQ0h0RlJyeUFBWlplMDZ4NEJabkpoYm1ObFl5MWtjMjF6In0.aGL0VkRadTtHjGuU7pbUHdUPsrrkr5-AB_kQx5yp8dr1CjXywDvKiFzuuihVEsV2jkQ6c2RGfOUpMj1rPpqCGAxxesbc0xpw9BqDD9o7ZdL9fdvHRSYiDdw_xrnTlOq9hWSOhvfLzhhIYbW_U3nMMP85daj3KehpTtxSKqtvhV5Fp1x-9r3JVi5-QuheTTCUOYzw9QbzoWi-n1y9XdoCJaC_zqAvKWjmSQR4ynn40KS3yAb8Titeb7rvfuhTtZusXkqBJVwlS4LXvMQ8U3eFDa0oz0O70YWh2wlJ_iUAm4t-8NXkAcYlVjqiZAp46ILmZx9vsWGAdYrJs4Xtc_dHZA"
# echo "Creating 50 FRPS grant applications..."


for i in $(seq 1 1); do
    CASE_REF="case-ref-$(date +%s)-$i"
    SBI="SBI$(printf "%03d" $i)"
    FRN="FIRM$(date +%s)$(printf "%04d" $i)$((RANDOM % 1000))"
    CRN="CUST$(printf "%04d" $i)"
    DEFRA_ID="DEFRA$(printf "%04d" $i)"
    
    # Generate random data for each application
    FIRST_NAMES=("Alice" "Bob" "Charlie" "Diana" "Edward" "Fiona" "George" "Hannah" "Ian" "Julia")
    LAST_NAMES=("Smith" "Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Davis" "Rodriguez" "Martinez")
    TITLES=("mr" "mrs" "miss" "ms" "dr")
    BUSINESS_NAMES=("Farming Solutions Ltd" "Agricultural Services Ltd" "Green Fields Ltd" "Rural Enterprises Ltd" "Farm Management Ltd")
    STREETS=("High Street" "Church Lane" "Mill Road" "Oak Avenue" "Elm Grove" "Meadow View" "Farm Road" "Village Green" "Manor Drive" "Chapel Street")
    AREAS=("Mulberry crescent" "Rose Gardens" "Willow Park" "Cedar Close" "Pine View" "Birch Way" "Holly Drive" "Ivy Court" "Maple Close" "Ash Lane")
    TOWNS=("Birmingham" "Manchester" "Leeds" "Sheffield" "Bristol" "Liverpool" "Newcastle" "Nottingham" "Southampton" "Portsmouth")
    CITIES=("London" "Birmingham" "Leeds" "Glasgow" "Sheffield" "Bradford" "Liverpool" "Edinburgh" "Manchester" "Bristol")
    POSTCODES=("B1 1AA" "M1 1AA" "LS1 1AA" "S1 1AA" "BS1 1AA" "L1 1AA" "NE1 1AA" "NG1 1AA" "SO14 1AA" "PO1 1AA")
    
    FIRST_NAME=${FIRST_NAMES[$((RANDOM % ${#FIRST_NAMES[@]}))]}
    LAST_NAME=${LAST_NAMES[$((RANDOM % ${#LAST_NAMES[@]}))]}
    TITLE=${TITLES[$((RANDOM % ${#TITLES[@]}))]}
    BUSINESS_NAME=${BUSINESS_NAMES[$((RANDOM % ${#BUSINESS_NAMES[@]}))]}
    STREET=${STREETS[$((RANDOM % ${#STREETS[@]}))]}
    AREA=${AREAS[$((RANDOM % ${#AREAS[@]}))]}
    TOWN=${TOWNS[$((RANDOM % ${#TOWNS[@]}))]}
    CITY=${CITIES[$((RANDOM % ${#CITIES[@]}))]}
    POSTCODE=${POSTCODES[$((RANDOM % ${#POSTCODES[@]}))]}
    
    # Generate random numbers for addresses and phones
    HOUSE_NUM=$((RANDOM % 999 + 1))
    PHONE_SUFFIX=$((RANDOM % 999999 + 100000))
    MOBILE_SUFFIX=$((RANDOM % 999999 + 100000))
    
    # Generate emails based on names
    FIRST_LOWER=$(echo "$FIRST_NAME" | tr '[:upper:]' '[:lower:]')
    LAST_LOWER=$(echo "$LAST_NAME" | tr '[:upper:]' '[:lower:]')
    BUSINESS_LOWER=$(echo "$BUSINESS_NAME" | sed 's/ //g' | sed 's/Ltd//g' | tr '[:upper:]' '[:lower:]')
    
    CUSTOMER_EMAIL="${FIRST_LOWER}.${LAST_LOWER}@example.com"
    BUSINESS_EMAIL="info@${BUSINESS_LOWER}.co.uk"
    
    echo "Creating application with caseRef: $CASE_REF"
    
    PAYLOAD="{
        \"metadata\": {
            \"clientRef\": \"$CASE_REF\",
            \"sbi\": \"$SBI\",
            \"frn\": \"$FRN\",
            \"crn\": \"$CRN\",
            \"defraId\": \"$DEFRA_ID\",
            \"createdAt\": \"2025-03-27T10:34:52.000Z\",
            \"submittedAt\": \"2025-03-28T11:30:52.000Z\"
        },
        \"answers\": {
            \"rulesCalculations\": {
                \"id\": $((2000 + i)),
                \"message\": \"Application validated successfully\",
                \"valid\": true,
                \"date\": \"2025-11-21T10:10:43.673Z\"
            },
            \"scheme\": \"SFI\",
            \"applicant\": {
                \"business\": {
                    \"reference\": \"1101313269\",
                    \"email\": { \"address\": \"$BUSINESS_EMAIL\" },
                    \"phone\": { \"mobile\": \"0044770090$MOBILE_SUFFIX\" },
                    \"name\": \"$BUSINESS_NAME\",
                    \"address\": {
                        \"line1\": \"$HOUSE_NUM $STREET\",
                        \"line2\": \"$AREA\",
                        \"line3\": null,
                        \"line4\": null,
                        \"line5\": null,
                        \"street\": \"$TOWN\",
                        \"city\": \"$CITY\",
                        \"postalCode\": \"$POSTCODE\"
                    }
                },
                \"customer\": {
                    \"name\": {
                        \"title\": \"$TITLE\",
                        \"first\": \"$FIRST_NAME\",
                        \"middle\": null,
                        \"last\": \"$LAST_NAME\"
                    }
                }
            },
            \"totalAnnualPaymentPence\": 70284,
            \"application\": {
                \"parcel\": [
                    {
                        \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
                        \"parcelId\": \"$((7555 + i))\",
                        \"area\": {
                            \"unit\": \"ha\",
                            \"quantity\": 5.2182
                        },
                        \"actions\": [
                            {
                                \"code\": \"CMOR1\",
                                \"version\": 1,
                                \"durationYears\": 3,
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 4.7575
                                }
                            },
                            {
                                \"code\": \"UPL3\",
                                \"version\": 1,
                                \"durationYears\": 3,
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 4.7575
                                }
                            }
                        ]
                    },
                    {
                        \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
                        \"parcelId\": \"$((9194 + i))\",
                        \"area\": {
                            \"unit\": \"ha\",
                            \"quantity\": 2.1703
                        },
                        \"actions\": [
                            {
                                \"code\": \"CMOR1\",
                                \"version\": 1,
                                \"durationYears\": 3,
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 2.1705
                                }
                            },
                            {
                                \"code\": \"UPL1\",
                                \"version\": 1,
                                \"durationYears\": 3,
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 2.1705
                                }
                            }
                        ]
                    }
                ],
                \"agreement\": []
            },
            \"payments\": {
                \"parcel\": [
                    {
                        \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
                        \"parcelId\": \"$((7555 + i))\",
                        \"area\": {
                            \"unit\": \"ha\",
                            \"quantity\": 5.2182
                        },
                        \"actions\": [
                            {
                                \"code\": \"CMOR1\",
                                \"description\": \"Assess moorland and produce a written record\",
                                \"durationYears\": 3,
                                \"paymentRates\": 1060,
                                \"annualPaymentPence\": 5042,
                                \"eligible\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 4.7575
                                },
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 4.7575
                                }
                            },
                            {
                                \"code\": \"UPL3\",
                                \"description\": \"Limited livestock grazing on moorland\",
                                \"durationYears\": 3,
                                \"paymentRates\": 6600,
                                \"annualPaymentPence\": 31399,
                                \"eligible\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 4.7575
                                },
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 4.7575
                                }
                            }
                        ]
                    },
                    {
                        \"sheetId\": \"SK$(printf "%04d" $((971 + i)))\",
                        \"parcelId\": \"$((9194 + i))\",
                        \"area\": {
                            \"unit\": \"ha\",
                            \"quantity\": 2.1703
                        },
                        \"actions\": [
                            {
                                \"code\": \"CMOR1\",
                                \"description\": \"Assess moorland and produce a written record\",
                                \"durationYears\": 3,
                                \"paymentRates\": 1060,
                                \"annualPaymentPence\": 2300,
                                \"eligible\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 2.1705
                                },
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 2.1705
                                }
                            },
                            {
                                \"code\": \"UPL1\",
                                \"description\": \"Moderate livestock grazing on moorland\",
                                \"durationYears\": 3,
                                \"paymentRates\": 2000,
                                \"annualPaymentPence\": 4341,
                                \"eligible\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 2.1705
                                },
                                \"appliedFor\": {
                                    \"unit\": \"ha\",
                                    \"quantity\": 2.1705
                                }
                            }
                        ]
                    }
                ],
                \"agreement\": [
                    {
                        \"code\": \"CMOR1\",
                        \"description\": \"Assess moorland and produce a written record\",
                        \"durationYears\": 3,
                        \"paymentRates\": 27200,
                        \"annualPaymentPence\": 27200
                    }
                ]
            }
        }
    }"
    
    echo "=== PAYLOAD BEING SENT ==="
    echo "$PAYLOAD" | jq '.' 2>/dev/null || echo "$PAYLOAD"
    echo "=========================="
    
    # Validate JSON before sending
    if echo "$PAYLOAD" | jq '.' >/dev/null 2>&1; then
        echo "JSON is valid, sending request..."
        curl --location "$BASE_URL" \
            --header 'accept: application/json' \
            --header 'Content-Type: application/json' \
            --header "x-api-key: $X_API_KEY" \
            --header "Authorization: Bearer $BEARER_TOKEN" \
            --data "$PAYLOAD"
    else
        echo "ERROR: JSON is invalid!"
        echo "$PAYLOAD" | jq '.' 2>&1
    fi
    
    echo
    echo "---"
done

echo "Completed creating 50 FRPS grant applications"

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