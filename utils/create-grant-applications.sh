#!/bin/bash

# Script to create 50 grant applications for performance testing
# BASE_URL="https://fg-gas-backend.perf-test.cdp-int.defra.cloud/grants/pigs-might-fly/applications"
BASE_URL="https://ephemeral-protected.api.dev.cdp-int.defra.cloud/fg-gas-backend/grants/pigs-might-fly/applications"

# API authentication parameters
X_API_KEY="a23raliahxBRIqjZ6PpUJG3XqMbrJXZH"
BEARER_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InlFVXdtWFdMMTA3Q2MtN1FaMldTYmVPYjNzUSIsImtpZCI6InlFVXdtWFdMMTA3Q2MtN1FaMldTYmVPYjNzUSJ9.eyJhdWQiOiJhcGk6Ly83NjBlMGM5OS1mODRhLTQ1ZTYtOWQ2MC00NzUwZmI1MDhhZmQiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83NzBhMjQ1MC0wMjI3LTRjNjItOTBjNy00ZTM4NTM3ZjExMDIvIiwiaWF0IjoxNzYyNDQxMjA3LCJuYmYiOjE3NjI0NDEyMDcsImV4cCI6MTc2MjQ0NTk1NywiYWNyIjoiMSIsImFpbyI6IkFiUUFTLzhhQUFBQVowUlphdmtpZDIwU1RtaE1iVVVBditaSGY0YVJvaHViaWh5aFVvVlRnN1V2cW1rbjFLcmtVZ2kyUDZsTGg1UGw0RHpMVVZmZXkrSkl3b204S2FxNjJsSkZMSVZwVzNURDc5MHhGd3g3L3pSODBZNWs5RUMvTmdXUjFxSWJRRDZsQ3FGUWxQMjQ5Ly91b1FoZEtCcWc1NUVESjhScDMxMHFHQ2hRSzNZK3RYcmZVaHlVd3luY1NleTNqR2pDeDVQOVlKUWhVTGFmTzhETC9vbjdKYmxpd0dYdFJXV0IvSS84ZTJkZDRDMEFlQm89IiwiYW1yIjpbIm90cCJdLCJhcHBpZCI6Ijc2MGUwYzk5LWY4NGEtNDVlNi05ZDYwLTQ3NTBmYjUwOGFmZCIsImFwcGlkYWNyIjoiMSIsImVtYWlsIjoibml0aW4ubWFsaUBlcXVhbGV4cGVydHMuY29tIiwiaWRwIjoibWFpbCIsImlwYWRkciI6IjIxMi41Ni4xMDcuMTM2IiwibmFtZSI6Im5pdGluLm1hbGkgKEd1ZXN0KSIsIm9pZCI6ImFiMzhmZDdmLTllZjQtNDQzYy05NWQ1LTM4MzUwZGFhNzc2ZCIsInJoIjoiMS5BUXdBVUNRS2R5Y0NZa3lReDA0NFUzOFJBcGtNRG5aSy1PWkZuV0JIVVB0UWl2ME1BT2NNQUEuIiwicm9sZXMiOlsiRkNQLkNhc2V3b3JrLkFkbWluIl0sInNjcCI6ImN3LmJhY2tlbmQiLCJzaWQiOiIwMGE4Y2IwOS00NTYzLWRkMzktNzg0Zi05NDMzOGVmZmY5NTYiLCJzdWIiOiJxZVp4NXlFeGxtS1BYTXRBUGRNTTN6dWVjQ2Jqc1FZaXdNTE5HdDlIRGpjIiwidGlkIjoiNzcwYTI0NTAtMDIyNy00YzYyLTkwYzctNGUzODUzN2YxMTAyIiwidW5pcXVlX25hbWUiOiJtYWlsI25pdGluLm1hbGlAZXF1YWxleHBlcnRzLmNvbSIsInV0aSI6IllOWWdGTmF6T0Vpa2g3QU9tMDRkQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfZnRkIjoiMGliSU5NdUFZRlJJS1FKX3FYbkh3RnJ5TzUzcjc5QVgtVWFuODJzb0xoUUJaWFZ5YjNCbGJtOXlkR2d0WkhOdGN3In0.SVuy9ZU5-waXAnLGn4C9U9C0ALFYgUU6y54vDe0pdsJmmLN6uahWZIL7UlFOeS4S_j_Vjv9M-qtT6Xl9_kgcC3fJCZEZsnj4-YEeA-h8ItCj5K6izpBuHDeD5B5tOyDK-rsnzJw_LDmXhZ28kai8iDRSFQK5h14VNjwLypggPr_5YCBqda-Stloz0K7XV5ThQc7YX1C-ioWExZrIWnoAI2KoeeJojQebO22mWKA4KydA_NkBBXCYwficlkNB3jZ11i-p1jMFenfHDgXC6hB9F3HYVdbZngOkizaioqp9IK_w5vy1rOqtSZ0JNztW-RT6rGa6xUCSLhMdSkpYskk7VA"

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