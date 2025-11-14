#!/bin/bash

# Script to create 50 FRPS grant applications for performance testing

# BASE_URL="https://fg-gas-backend.perf-test.cdp-int.defra.cloud/grants/frps-private-beta/applications"
BASE_URL=https://ephemeral-protected.api.dev.cdp-int.defra.cloud/fg-gas-backend/grants/frps-private-beta/applications

# API authentication parameters
X_API_KEY="1mfGefxNGpQ6Y2lmeUBAYuHIoC0mMqk7"
BEARER_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyIsImtpZCI6InJ0c0ZULWItN0x1WTdEVlllU05LY0lKN1ZuYyJ9.eyJhdWQiOiJhcGk6Ly83NjBlMGM5OS1mODRhLTQ1ZTYtOWQ2MC00NzUwZmI1MDhhZmQiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83NzBhMjQ1MC0wMjI3LTRjNjItOTBjNy00ZTM4NTM3ZjExMDIvIiwiaWF0IjoxNzYzMTE2NjgzLCJuYmYiOjE3NjMxMTY2ODMsImV4cCI6MTc2MzEyMTg3MiwiYWNyIjoiMSIsImFpbyI6IkFiUUFTLzhhQUFBQU1UWGJTQ3BKd2xrbEhPNHY1R2VmRDhHcDN5YjNXWnBKL255TkhPVFBVbVh2U1RQa0M0K3NxNy95Zk9WZmVjaWtOMzJYY1E1WDYwMDJrWFJ5SjBVTm8yM1NVeXJ2ZEJlQ2Z0U1h0dDF4R2F5bW9SUHZNYVRtOW40Z1FTSVNtMzFscnBhTCsyaHhNZEFoU1hiRzFZVmlIQ0VJV2s5RG9McjNnYUt0aThBZUpkVDJCbGZKZmdVTEx2K3hRR2hQc21acngycnlmYU1JbUJJTGIwb1BYV2hWUXJ0R2luU1NKZHovRjVFeTFIaE1PcDQ9IiwiYW1yIjpbIm90cCJdLCJhcHBpZCI6Ijc2MGUwYzk5LWY4NGEtNDVlNi05ZDYwLTQ3NTBmYjUwOGFmZCIsImFwcGlkYWNyIjoiMSIsImVtYWlsIjoibml0aW4ubWFsaUBlcXVhbGV4cGVydHMuY29tIiwiaWRwIjoibWFpbCIsImlwYWRkciI6IjIxMi41Ni4xMDcuMTM2IiwibmFtZSI6Im5pdGluLm1hbGkgKEd1ZXN0KSIsIm9pZCI6ImFiMzhmZDdmLTllZjQtNDQzYy05NWQ1LTM4MzUwZGFhNzc2ZCIsInJoIjoiMS5BUXdBVUNRS2R5Y0NZa3lReDA0NFUzOFJBcGtNRG5aSy1PWkZuV0JIVVB0UWl2ME1BT2NNQUEuIiwicm9sZXMiOlsiRkNQLkNhc2V3b3JrLkFkbWluIl0sInNjcCI6ImN3LmJhY2tlbmQiLCJzaWQiOiIwMGFhMDM4OS05MWNmLWEzYzItNTMyZC1jNTJmMjBhYmNkZjgiLCJzdWIiOiJxZVp4NXlFeGxtS1BYTXRBUGRNTTN6dWVjQ2Jqc1FZaXdNTE5HdDlIRGpjIiwidGlkIjoiNzcwYTI0NTAtMDIyNy00YzYyLTkwYzctNGUzODUzN2YxMTAyIiwidW5pcXVlX25hbWUiOiJtYWlsI25pdGluLm1hbGlAZXF1YWxleHBlcnRzLmNvbSIsInV0aSI6Il81WVN1WnJESGtXLWN2VDR2bk5kQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfZnRkIjoiMEx4eExUZmxxQkhrN2o5Wkw0RnJ4UWl2YVNTZzdlUHI5M2pKcEFOVWNLb0JjM2RsWkdWdVl5MWtjMjF6In0.iHlxAg-95TW71GaaP3PxsyWOQ9R7Rr6IM2afLGP9PfeumUUAuGi_VEBel72BTCRbRq3sWPNAbJd5knZ9XhW0-nee72t7ADTQ3wesCnHj2sru6wUPDeJUVgWwKbz6B8gDQH4Fgux4sM4BDpTEXRYhlcSwKK3YHJqqWHH5yXnxFp1JmkqJkJqcTTgDmtTsfC4SVjZKUUOplEHf7jkiXS5Via7Znt9iWIAb3yL4JX_7BZbYAbyhriHzebBNHgM17bQU9YFvN5fmQD7WaNFgbO2yF_HkjobGvCJoB4k-MfrQakCKFALlWvnCM8HYuXBcaNDT5Xjngf1mWlCh0KjXyDP4mg"
echo "Creating 50 FRPS grant applications..."

for i in $(seq 1 1); do
    CASE_REF="case-ref-$(date +%s)-$i"
    SBI="SBI$(printf "%03d" $i)"
    FRN="FIRM$(printf "%04d" $i)"
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
            \"applicationValidationRunId\": 123,
            \"scheme\": \"SFI\",
            \"year\": 2025,
            \"hasCheckedLandIsUpToDate\": true,
            \"applicant\": {
                \"business\": {
                    \"reference\": \"1101313269\",
                    \"email\": { \"address\": \"$BUSINESS_EMAIL\" },
                    \"phone\": { \"mobile\": \"0044770090$MOBILE_SUFFIX\" },
                    \"name\": \"$BUSINESS_NAME\",
                    \"address\": {
                        \"line1\": \"$HOUSE_NUM $STREET\",
                        \"line2\": \"$AREA\",
                        \"line3\": \"Haute Vienne\",
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
            \"totalAnnualPaymentPence\": 35150,
            \"parcels\": [
                {
                    \"sheetId\": \"AB$((1234 + i))\",
                    \"parcelId\": \"$((10001 + i))\",
                    \"area\": {
                        \"unit\": \"ha\",
                        \"quantity\": 10.0
                    },
                    \"actions\": [
                        {
                            \"code\": \"CMOR1\",
                            \"description\": \"Assess moorland and produce a written record\",
                            \"durationYears\": 3,
                            \"eligible\": {
                                \"unit\": \"ha\",
                                \"quantity\": 7.5
                            },
                            \"appliedFor\": {
                                \"unit\": \"ha\",
                                \"quantity\": 7.5
                            },
                            \"paymentRates\": {
                                \"ratePerUnitPence\": 1060,
                                \"agreementLevelAmountPence\": 27200
                            },
                            \"annualPaymentPence\": 35150
                        }
                    ]
                },
                {
                    \"sheetId\": \"DX$((1234 + i))\",
                    \"parcelId\": \"$((10002 + i))\",
                    \"area\": {
                        \"unit\": \"ha\",
                        \"quantity\": 10.0
                    },
                    \"actions\": [
                        {
                            \"code\": \"UPL1\",
                            \"description\": \"Assess moorland and produce a written record\",
                            \"durationYears\": 3,
                            \"eligible\": {
                                \"unit\": \"ha\",
                                \"quantity\": 7.5
                            },
                            \"appliedFor\": {
                                \"unit\": \"ha\",
                                \"quantity\": 7.5
                            },
                            \"paymentRates\": {
                                \"ratePerUnitPence\": 1060,
                                \"agreementLevelAmountPence\": 27200
                            },
                            \"annualPaymentPence\": 35150
                        }
                    ]
                }
            ],
            \"actionApplications\": [
                {
                    \"parcelId\": \"$((10001 + i))\",
                    \"sheetId\": \"AB$((1234 + i))\",
                    \"code\": \"CMOR1\",
                    \"appliedFor\": {
                        \"unit\": \"ha\",
                        \"quantity\": 7.5
                    }
                },
                {
                    \"parcelId\": \"$((10002 + i))\",
                    \"sheetId\": \"DX$((1234 + i))\",
                    \"code\": \"UPL1\",
                    \"appliedFor\": {
                        \"unit\": \"ha\",
                        \"quantity\": 7.5
                    }
                }
            ],
            \"payment\": {
                \"agreementStartDate\": \"2025-09-01\",
                \"agreementEndDate\": \"2026-08-31\",
                \"frequency\": \"Monthly\",
                \"agreementTotalPence\": 35150,
                \"annualTotalPence\": 35150,
                \"parcelItems\": {
                    \"description\": \"Moorland assessment agreement\",
                    \"annualPaymentPence\": 35150
                },
                \"agreementLevelItems\": {
                    \"type\": \"adminFee\",
                    \"annualPaymentPence\": 0
                },
                \"payments\": [
                    {
                        \"paymentDate\": \"2025-10-01\",
                        \"totalPaymentPence\": 2929,
                        \"lineItems\": [
                            {
                                \"description\": \"Monthly moorland assessment payment\",
                                \"paymentPence\": 2929
                            }
                        ]
                    }
                ]
            }
        }
    }"
    
    echo "=== PAYLOAD BEING SENT ==="
    echo "$PAYLOAD" | jq '.' 2>/dev/null || echo "$PAYLOAD"
    echo "=========================="
    
    curl --location "$BASE_URL" \
        --header 'accept: application/json' \
        --header 'Content-Type: application/json' \
        --header "x-api-key: $X_API_KEY" \
        --header "Authorization: Bearer $BEARER_TOKEN" \
        --data "$PAYLOAD"
    
    echo
    echo "---"
done

echo "Completed creating 50 FRPS grant applications"