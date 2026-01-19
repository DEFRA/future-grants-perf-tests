/**
 * Perform Entra ID (Microsoft login) flow AND dump the CW-FE session cookie for JMeter.
 *
 * Usage idea:
 *  - Run this once before perf tests
 *  - It writes a JSON file JMeter can read
 */

import fs from 'node:fs/promises'
import path from 'node:path'

export async function entraLoginAndDumpSessionCookie(
  username,
  password,
  {
    expectedDomain = 'fg-cw-frontend',
    // Set this to the *actual* cookie name your app sets after successful login.
    // Common patterns: 'CW-FE', 'cw-fe', 'connect.sid', 'session', etc.
    appSessionCookieName = 'CW-FE',
    outputFile = './artifacts/cw-fe-session.json',
    casesUrl = null
  } = {}
) {
  await performLogin(username, password)
  await waitForAppLoadOrRetry(expectedDomain, username, password)

  // Assert we're on the app domain
  const currentUrl = await browser.getUrl()
  console.log(`\n✓ Successfully logged in. Current URL: ${currentUrl}`)

  if (!currentUrl.includes(expectedDomain)) {
    throw new Error(
      `Expected to be on domain "${expectedDomain}" but got: ${currentUrl}`
    )
  }
  console.log(`✓ Confirmed we're on the app domain: ${expectedDomain}`)

  // Navigate to a page that requires auth to force session creation
  if (casesUrl) {
    console.log(`\nNavigating to authenticated page: ${casesUrl}`)
    await browser.url(casesUrl)
    await browser.pause(3000) // Wait for page to load and session to be created

    const casesPageUrl = await browser.getUrl()
    console.log(`✓ Navigated to cases page: ${casesPageUrl}`)
  }

  // Now dump cookies from the browser after session is fully established
  console.log('\nDumping cookies...')
  const cookies = await browser.getCookies()
  console.log(`Found ${cookies.length} cookies:`, cookies.map((c) => c.name).join(', '))

  const appCookie = cookies.find((c) => c.name === appSessionCookieName)

  if (!appCookie || !appCookie.value) {
    // Brutal truth: if this fails, it means your app didn't set the cookie OR it's HttpOnly + different domain
    // (domain mismatch) OR you're not actually landing on the app.
    throw new Error(
      `Login succeeded but could not find cookie "${appSessionCookieName}". ` +
        `Found: ${cookies.map((c) => c.name).join(', ')}`
    )
  }

  console.log(`✓ Found session cookie: ${appSessionCookieName}`)

  // Write JSON artifact for JMeter
  const outDir = path.dirname(outputFile)
  await fs.mkdir(outDir, { recursive: true })

  // Simplified payload with only what JMeter needs
  const jmeterPayload = {
    createdAt: new Date().toISOString(),
    expiresAt: appCookie.expiry ? new Date(appCookie.expiry * 1000).toISOString() : null,
    cookieName: appCookie.name,
    cookieValue: appCookie.value,
    cookieHeader: `${appCookie.name}=${appCookie.value}`,
    domain: appCookie.domain,
    path: appCookie.path || '/',
    secure: appCookie.secure || false
  }

  await fs.writeFile(outputFile, JSON.stringify(jmeterPayload, null, 2), 'utf-8')
  console.log(`\n✓ Wrote session cookie to ${outputFile}`)

  // Also write CSV file for JMeter CSV Data Set Config
  // Navigate to project root: artifacts -> auth/run -> auth -> project root
  const csvDir = path.join(path.dirname(outputFile), '..', '..', '..', 'data')
  await fs.mkdir(csvDir, { recursive: true })
  const csvFile = path.join(csvDir, 'session-cookies.csv')

  // Check if CSV file exists and has content
  let csvContent = ''
  try {
    const existingContent = await fs.readFile(csvFile, 'utf-8')
    const lines = existingContent.trim().split('\n')
    if (lines.length > 0 && lines[0] === 'cookieHeader') {
      // File exists with header, append new cookie
      csvContent = existingContent.trim() + '\n' + jmeterPayload.cookieHeader
      console.log(`✓ Appended cookie to existing CSV file: ${csvFile}`)
    } else {
      // File exists but no header, recreate
      csvContent = `cookieHeader\n${jmeterPayload.cookieHeader}`
      console.log(`✓ Wrote CSV file to ${csvFile}`)
    }
  } catch (error) {
    // File doesn't exist, create new with header
    csvContent = `cookieHeader\n${jmeterPayload.cookieHeader}`
    console.log(`✓ Wrote new CSV file to ${csvFile}`)
  }

  await fs.writeFile(csvFile, csvContent, 'utf-8')

  console.log(`\n📋 For JMeter, use this Cookie header:`)
  console.log(`   ${jmeterPayload.cookieHeader}`)
  console.log(`\n⏰ Cookie expires at: ${jmeterPayload.expiresAt || 'N/A'}`)
}

/**
 * Existing functions below (unchanged unless noted)
 */

export async function entraLogin(username, password) {
  const expectedDomain = 'fg-cw-frontend'
  await performLogin(username, password)
  await waitForAppLoadOrRetry(expectedDomain, username, password)
  console.log(`Entra ID login successful for ${username}`)
}

export async function entraLocalLogin(username, password) {
  await performLocalLogin(username, password)
  console.log(`Entra ID login successful for ${username}`)
}

export async function performLocalLogin(username, password) {
  const emailField = await $('#username')
  await emailField.waitForDisplayed({ timeout: 15000 })
  await emailField.setValue(username)

  const passwordField = await $('#password')
  await passwordField.waitForDisplayed({ timeout: 15000 })
  await passwordField.setValue(password)

  await clickButtonByText('Login')
}

async function performLogin(username, password) {
  console.log('Looking for email field...')
  // Use name attribute which is more stable than id
  const emailField = await $('[name="loginfmt"]')
  await emailField.waitForDisplayed({ timeout: 15000 })
  console.log('Email field found, entering username...')
  await emailField.setValue(username)

  console.log('Clicking Next button...')
  const nextButton = await $('#idSIButton9')
  await nextButton.waitForClickable({ timeout: 10000 })
  await nextButton.click()

  // Give the page time to transition
  await browser.pause(2000)

  console.log('Waiting for password field...')
  // Use name attribute which is more stable than id
  const passwordField = await $('[name="passwd"]')
  await passwordField.waitForDisplayed({ timeout: 20000 })
  console.log('Password field found, entering password...')
  await passwordField.setValue(password)

  await clickSignInWithRetry()
}

async function waitForAppLoadOrRetry(expectedDomain, username, password) {
  let retryCount = 0
  const maxRetries = 2

  await browser.waitUntil(
    async () => {
      const currentUrl = await browser.getUrl()
      if (currentUrl.includes(expectedDomain)) return true

      if (
        currentUrl.includes('login.microsoftonline.com') &&
        retryCount < maxRetries
      ) {
        retryCount++
        await performRetryLogin(username, password)
      }
      return false
    },
    {
      timeout: 60000,
      interval: 2000,
      timeoutMsg: 'App did not load after Entra ID login redirect'
    }
  )
}

async function performRetryLogin(username, password) {
  console.log('Attempting retry login...')

  // Use name attribute which is more stable than id
  const emailField = await $('[name="loginfmt"]')
  if (await emailField.isDisplayed()) {
    console.log('Retrying login (email page detected)')
    await emailField.setValue(username)
    await (await $('#idSIButton9')).click()
    await browser.pause(2000)
  }

  // Use name attribute which is more stable than id
  const passwordField = await $('[name="passwd"]')
  if (await passwordField.isDisplayed()) {
    console.log('Password field detected, entering password...')
    await passwordField.setValue(password)
    await (await $('#idSIButton9')).click()
    await browser.pause(2000)
  }

  const staySignedIn = await $('#idBtn_Back')
  if (await staySignedIn.isDisplayed()) {
    console.log('Stay signed in prompt detected, clicking No...')
    await staySignedIn.click()
  }
}

async function clickSignInWithRetry(maxRetries = 3) {
  const signInButtonSelector = '#idSIButton9'
  const loginHeaderSelector = '#loginHeader'

  console.log('Clicking Sign In button...')

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    console.log(`Sign In attempt ${attempt} of ${maxRetries}`)

    const signInButton = await $(signInButtonSelector)
    await signInButton.waitForDisplayed({ timeout: 10000 })
    await signInButton.waitForEnabled({ timeout: 10000 })
    await signInButton.scrollIntoView()
    await signInButton.moveTo()
    await signInButton.click()
    await browser.pause(3000)

    const currentUrl = await browser.getUrl()
    console.log(`Current URL: ${currentUrl}`)

    // Check if we're still on Microsoft login page
    if (!currentUrl.includes('login.microsoftonline.com')) {
      console.log('Successfully left Microsoft login page')
      return
    }

    const loginHeader = await $(loginHeaderSelector)
    if (await loginHeader.isDisplayed()) {
      const headerText = (await loginHeader.getText()).trim()
      console.log(`Login header text: "${headerText}"`)
      if (headerText === 'Enter password') {
        console.warn(`Still on password page (attempt ${attempt}). Retrying...`)
        continue
      }
    }

    console.warn(`Still on login.microsoftonline.com (attempt ${attempt}). Retrying...`)
  }

  throw new Error('Login stuck on password page after multiple retries.')
}

async function clickButtonByText(text) {
  const button = await $(`button=${text}`)
  await button.waitForClickable({ timeout: 10000 })
  await button.click()
}
