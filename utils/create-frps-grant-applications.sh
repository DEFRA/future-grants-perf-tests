#!/bin/bash

# Script to create 50 FRPS grant applications for performance testing
BASE_URL="https://fg-gas-backend.perf-test.cdp-int.defra.cloud/grants/frps-private-beta/applications"

echo "Creating 50 FRPS grant applications..."

for i in $(seq 1 50); do
    CLIENT_REF="frps-perf-test-client-ref-$(printf "%010d" $((86059144474 + i)))"
    SBI="$(printf "%09d" $((106284736 + i)))"
    DEFRA_ID="$(printf "%011d" $((12345678910 + i)))"
    
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
    
    echo "Creating application with clientRef: $CLIENT_REF"
    
    curl --location "$BASE_URL" \
        --header 'accept: application/json' \
        --header 'Content-Type: application/json' \
        --data "{
            \"metadata\": {
                \"clientRef\": \"$CLIENT_REF\",
                \"sbi\": \"$SBI\",
                \"frn\": \"1234567\",
                \"crn\": \"1102838829\",
                \"defraId\": \"$DEFRA_ID\",
                \"createdAt\": \"2025-10-06T09:46:47.000Z\",
                \"submittedAt\": \"2025-10-07T09:46:47.000Z\"
            },
            \"answers\": {
                \"scheme\": \"SFI\",
                \"year\": 2025,
                \"hasCheckedLandIsUpToDate\": true,
                \"agreementName\": \"AT Farming agreement\",
                \"applicationValidationRunId\": \"SFI grants\",
                \"payment\": {
                    \"agreementStartDate\": \"2025-09-01\",
                    \"agreementEndDate\": \"2026-08-31\",
                    \"frequency\": \"Monthly\",
                    \"agreementTotalPence\": 1200000,
                    \"annualTotalPence\": 1200000,
                    \"parcelItems\": {
                        \"description\": \"Main agreement\",
                        \"annualPaymentPence\": 1200000
                    },
                    \"agreementLevelItems\": {
                        \"type\": \"adminFee\",
                        \"annualPaymentPence\": 10000
                    },
                    \"payments\": [
                        {
                            \"paymentDate\": \"2025-10-01\",
                            \"totalPaymentPence\": 100000,
                            \"lineItems\": [
                                {
                                    \"description\": \"Monthly lease payment\",
                                    \"paymentPence\": 100000
                                }
                            ]
                        },
                        {
                            \"paymentDate\": \"2025-11-01\",
                            \"totalPaymentPence\": 100000,
                            \"lineItems\": [
                                {
                                    \"description\": \"Monthly lease payment\",
                                    \"paymentPence\": 100000
                                }
                            ]
                        }
                    ]
                },
                \"applicant\": {
                    \"customer\": {
                        \"name\": {
                            \"title\": \"$TITLE\",
                            \"first\": \"$FIRST_NAME\",
                            \"last\": \"$LAST_NAME\"
                        },
                        \"email\": { \"address\": \"$CUSTOMER_EMAIL\" },
                        \"phone\": { \"number\": \"+4477009$PHONE_SUFFIX\" }
                    },
                    \"business\": {
                        \"name\": \"$BUSINESS_NAME\",
                        \"type\": \"LTD\",
                        \"email\": { \"address\": \"$BUSINESS_EMAIL\" },
                        \"phone\": { \"mobile\": \"0044770090$MOBILE_SUFFIX\" },
                        \"address\": {
                            \"line1\": \"$HOUSE_NUM $STREET\",
                            \"line2\": \"$AREA\",
                            \"street\": \"$TOWN\",
                            \"city\": \"$CITY\",
                            \"postalCode\": \"$POSTCODE\",
                            \"country\": \"UK\"
                        }
                    }
                },
                \"actionApplications\": [
                    {
                        \"parcelId\": \"9238\",
                        \"sheetId\": \"SX0679\",
                        \"code\": \"CSAM1\",
                        \"appliedFor\": {
                            \"unit\": \"ha\",
                            \"quantity\": 20.23
                        }
                    }
                ]
            }
        }"
    
    echo
    echo "---"
done

echo "Completed creating 50 FRPS grant applications"