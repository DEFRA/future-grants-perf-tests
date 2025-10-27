#!/bin/bash

# Script to create 50 users for performance testing
BASE_URL="https://fg-cw-backend.perf-test.cdp-int.defra.cloud/users"

echo "Creating 50 users..."

for i in $(seq -w 1 50); do
    USER_NUM=$(printf "%02d" $i)
    EMAIL="perf-tester-$USER_NUM@defra.gov.uk"
    NAME="Perf Tester$USER_NUM"
    # Generate unique idpId by changing the last part of the UUID
    IDP_ID="123e4567-e89b-12d3-a456-$(printf "42661417%04d" $i)"
    
    echo "Creating user: $EMAIL with idpId: $IDP_ID"
    
    curl -X 'POST' \
        "$BASE_URL" \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d "{
            \"idpId\": \"$IDP_ID\",
            \"email\": \"$EMAIL\",
            \"name\": \"$NAME\",
            \"idpRoles\": [
                \"FCP.Casework.Read\"
            ],
            \"appRoles\": {
                \"ROLE_RPA_ADMIN\": {
                    \"startDate\": \"2025-01-31\",
                    \"endDate\": \"2027-10-31\"
                }
            }
        }"
    
    echo
    echo "---"
done

echo "Completed creating 50 users"