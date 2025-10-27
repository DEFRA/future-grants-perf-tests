#!/bin/bash

# FRPS API Test Script
set -e

# Configuration - Update these values as needed
API_BASE_URL="https://ephemeral-protected.api.perf-test.cdp-int.defra.cloud/fg-cw-backend"
JWT_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InlFVXdtWFdMMTA3Q2MtN1FaMldTYmVPYjNzUSIsImtpZCI6InlFVXdtWFdMMTA3Q2MtN1FaMldTYmVPYjNzUSJ9.eyJhdWQiOiJhcGk6Ly83NjBlMGM5OS1mODRhLTQ1ZTYtOWQ2MC00NzUwZmI1MDhhZmQiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83NzBhMjQ1MC0wMjI3LTRjNjItOTBjNy00ZTM4NTM3ZjExMDIvIiwiaWF0IjoxNzYxMjQ0NDQ1LCJuYmYiOjE3NjEyNDQ0NDUsImV4cCI6MTc2MTI0OTc5MywiYWNyIjoiMSIsImFpbyI6IkFYUUFpLzhhQUFBQTBCZVhXeStkdWJQbjRGcHFHUnZPbStPR0dTakUwRjJDNTY5Nmh6a2RpbkN2cVZxdkRuUk51MFNoZ1RqMktHa0Zod2dRRDVxOEVJdXNwRkJ5cGhaREMyeWhSY0d6K0hnZDAxc0ZlbVJYeTNLWjNna0Q0bWJvcFNBOW81OTFPcFY3RStQTE5HY2hIM3doOXFMUG9Pd2pFdz09IiwiYW1yIjpbInB3ZCJdLCJhcHBpZCI6Ijc2MGUwYzk5LWY4NGEtNDVlNi05ZDYwLTQ3NTBmYjUwOGFmZCIsImFwcGlkYWNyIjoiMSIsImVtYWlsIjoiU0EtRkdDVy5BRE1JTkBkZWZyYS5vbm1pY3Jvc29mdC5jb20iLCJmYW1pbHlfbmFtZSI6IkFETUlOIiwiZ2l2ZW5fbmFtZSI6IlNBLUZHQ1ciLCJpcGFkZHIiOiIyMTIuNTYuMTA3LjEzNiIsIm5hbWUiOiJTQS1GR0NXIEFETUlOIChFcXVhbCBFeHBlcnRzKSIsIm9pZCI6IjI3MWU3M2M0LWM4NjQtNGIxNy1iMWJlLTY4NTcwZDYwYzkwYSIsInJoIjoiMS5BUXdBVUNRS2R5Y0NZa3lReDA0NFUzOFJBcGtNRG5aSy1PWkZuV0JIVVB0UWl2ME1BRFVNQUEuIiwicm9sZXMiOlsiRkNQLkNhc2V3b3JrLkFkbWluIl0sInNjcCI6ImN3LmJhY2tlbmQiLCJzaWQiOiIwMDljMjBkOS1lNzg5LTVjOWYtZTlmNi0zYjMzNmJkODcxMTEiLCJzdWIiOiJtU1NoRGNFR1VoS3ZPRmZuR25vQ2FpZ2FON0ZrT3puMlFiZHUwdUFqYTBBIiwidGlkIjoiNzcwYTI0NTAtMDIyNy00YzYyLTkwYzctNGUzODUzN2YxMTAyIiwidW5pcXVlX25hbWUiOiJTQS1GR0NXLkFETUlOQGRlZnJhLm9ubWljcm9zb2Z0LmNvbSIsInVwbiI6IlNBLUZHQ1cuQURNSU5AZGVmcmEub25taWNyb3NvZnQuY29tIiwidXRpIjoiYjk1ODVJX2oyVVd3UFM0M1RpSUJBQSIsInZlciI6IjEuMCIsInhtc19mdGQiOiIydHEyVzVhMWpqWF9RQnF6eDA2cVROSWZGdURodVVOdWlJWjljZHVtczJFQlpYVnliM0JsZDJWemRDMWtjMjF6In0.P6kN2N2cp6memP6d3-wWinLsT-_gBR3ZfGGzov78bE17tsICUqjh8kil5C0CwyXit-PmKBI5R5rEl3m082yBU4CZGyMArNA4mwPvjBfoBQXnc8svM4DFuOrdYAESMQUWsRv9DuUljI3NwlYcXuz6XUM5khDF5sfZacj02Xforw2T6XhiRXLD3yHZHI5O_Fzao_ZcEcJMcCYFpPm0PQgJcMXghpBD7E1t5HBp2K8_xqOKbchTeuTuvuoFJg0X00LDn7e2NFlPGlbWFGjOvFq4m450sAL9MpUJrR3xI1TBMrbZy_X4RGJcEK2fOHsCbqo1PrKhUJ80uyIps6XdPovK8g"
X_API_KEY="6QK0HOO85yA1FeR5Aaz7FJhf7B3ZMyCW"

# Test case configuration
CASE_ID="68e517ab22faca9b82839da3"

echo "🚀 FRPS API Test"
echo "API: ${API_BASE_URL}"
echo "Case ID: ${CASE_ID}"
echo ""

# Step 1: Get all cases
echo "1. Getting all cases..."
response=$(curl -s --location "${API_BASE_URL}/cases" \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 2: Get specific case details
echo "2. Getting case details for ${CASE_ID}..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}" \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 3: Get workflow details
echo "3. Getting FRPS workflow..."
response=$(curl -s --location "${API_BASE_URL}/workflows/frps-private-beta" \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 4: Assign case (PATCH - refer to swagger for payload)
echo "4. Assigning case..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}/assigned-user" \
  --request PATCH \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}" \
  --data '{
    "assignedUserId": "68d3ff518cdbf7078ef18e31",
    "notes": "Assigned for performance testing"
  }')
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 5: Get cases again (refresh after assignment)
echo "5. Getting cases after assignment..."
response=$(curl -s --location "${API_BASE_URL}/cases" \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 6: Get case details again
echo "6. Getting updated case details..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}" \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 7: Complete simple review task (PATCH - refer to swagger for payload)
echo "7. Completing simple review task..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}/stages/application-receipt/task-groups/application-receipt-tasks/tasks/simple-review/status" \
  --request PATCH \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}" \
  --data '{
    "status": "complete",
    "comment": "Simple review completed via performance test"
  }')
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 8: Approve the case (PATCH - refer to swagger for payload)
echo "8. Approving the case..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}/stage/outcome" \
  --request PATCH \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}" \
  --data '{
    "actionId": "approve",
    "comment": "Application approved via API performance test"
  }')
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 9: Get case details tab
echo "9. Getting case details tab..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}/tabs/case-details" \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 10: Add case note (POST - refer to swagger for payload)
echo "10. Adding case note..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}/notes" \
  --request POST \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}" \
  --data '{
    "text": "Performance test note added via API"
  }'
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

# Step 11: Get agreements tab
echo "11. Getting agreements tab..."
response=$(curl -s --location "${API_BASE_URL}/cases/${CASE_ID}/tabs/agreements" \
  --header 'Accept: application/json' \
  --header "Authorization: Bearer ${JWT_TOKEN}" \
  --header "x-api-key: ${X_API_KEY}")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo "⏳ Waiting 5 seconds..."
sleep 5

echo "✅ Complete FRPS case processing journey finished!"
echo "Case ${CASE_ID} has been processed through all steps."