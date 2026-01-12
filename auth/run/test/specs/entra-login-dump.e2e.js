import { entraLoginAndDumpSessionCookie } from '../utils/loginHelper.js'

describe('Entra ID Login and Cookie Dump', () => {
  it('should perform Entra ID login and dump CW-FE session cookie for JMeter', async () => {
    const username = process.env.ENTRA_ID_USERNAME || process.env.ENTRA_ID_ADMIN_USER
    const password = process.env.ENTRA_ID_PASSWORD || process.env.ENTRA_ID_USER_PASSWORD

    if (!username || !password) {
      throw new Error(
        'Environment variables ENTRA_ID_USERNAME and ENTRA_ID_PASSWORD are required. ' +
        'Please set them in your .env file or environment.'
      )
    }

    console.log('\n' + '='.repeat(80))
    console.log('ENTRA ID LOGIN AND SESSION COOKIE EXTRACTION')
    console.log('='.repeat(80))
    console.log(`\nUser: ${username}`)
    console.log(`Output: ${process.env.OUTPUT_FILE || './artifacts/cw-fe-session.json'}`)
    console.log('\n')

    // Navigate to your application URL
    const appUrl = process.env.APP_URL || 'https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/'
    console.log(`Navigating to: ${appUrl}`)
    await browser.url(appUrl)

    // Perform login and dump cookie
    await entraLoginAndDumpSessionCookie(username, password, {
      expectedDomain: process.env.EXPECTED_DOMAIN || 'fg-cw-frontend',
      appSessionCookieName: process.env.COOKIE_NAME || 'CW-FE',
      outputFile: process.env.OUTPUT_FILE || './artifacts/cw-fe-session.json',
      casesUrl: process.env.CASES_URL || 'https://fg-cw-frontend.perf-test.cdp-int.defra.cloud/cases'
    })

    console.log('\n' + '='.repeat(80))
    console.log('✓ SUCCESS - Session cookie dumped for JMeter')
    console.log('='.repeat(80) + '\n')
  })
})
