# GitHub Actions Setup

This document explains how to set up the GitHub Actions workflow for performance testing.

## Prerequisites

The workflow generates session cookies using Entra ID authentication before running JMeter tests. This requires setting up GitHub secrets with valid credentials.

## Required GitHub Secrets

You need to add the following secrets to your GitHub repository:

1. **`ENTRA_ID_USERNAME`**
   - The Entra ID username/email for authentication
   - Example: `SA-FGCW.ADMIN@defra.onmicrosoft.com`

2. **`ENTRA_ID_PASSWORD`**
   - The password for the Entra ID account
   - This should be a secure password

### How to Add Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its name and value
5. Click **Add secret**

## Workflow Steps

The workflow performs the following steps:

1. **Checkout code** - Gets the latest code
2. **Set up Node.js** - Installs Node.js 20
3. **Install Chrome** - Installs Chrome browser for WebDriver
4. **Install auth dependencies** - Installs npm packages for authentication
5. **Set up Entra ID credentials** - Creates `.env` file with secrets
6. **Generate session cookies** - Runs `generate-multiple-cookies.sh 10` to create 10 cookies
7. **Verify cookies** - Checks that `test-data/session-cookies.csv` was created
8. **Build the test suite** - Runs JMeter tests with the generated cookies

## Cookie Generation

The workflow generates **10 session cookies** by default. These cookies are stored in:
```
test-data/session-cookies.csv
```

Each cookie is obtained by:
1. Logging into the application via Entra ID
2. Navigating to `/cases` page
3. Extracting the session cookie
4. Appending it to the CSV file

## Customization

To change the number of cookies generated, edit this line in `.github/workflows/publish.yml`:

```yaml
./generate-multiple-cookies.sh 10
```

Change `10` to your desired number of cookies.

## Troubleshooting

### Cookie generation fails

Check the workflow logs for errors in the "Generate session cookies for JMeter" step. Common issues:

- Invalid credentials (check secrets)
- Network timeout (application not accessible)
- Chrome/WebDriver issues (check Chrome installation step)

### Cookies not found

If the "Verify cookies were generated" step fails, it means the CSV file wasn't created. Check the previous step's logs.

## Local Testing

To test cookie generation locally:

```bash
cd auth/run

# Create .env file with your credentials
cat > .env << EOF
ENTRA_ID_USERNAME=your-username@defra.onmicrosoft.com
ENTRA_ID_PASSWORD=your-password
APP_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/
EXPECTED_DOMAIN=fg-cw-frontend
COOKIE_NAME=session
OUTPUT_FILE=./artifacts/cw-fe-session.json
CASES_URL=https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases
EOF

# Install dependencies
npm install

# Generate cookies
./generate-multiple-cookies.sh 10
```
