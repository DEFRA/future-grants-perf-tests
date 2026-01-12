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
    outputFile = './artifacts/cw-fe-session.json'
  } = {}
) {
  await performLogin(username, password)
  await waitForAppLoadOrRetry(expectedDomain, username, password)

  // We are now on the app domain. Pull cookies from the browser.
  const cookies = await browser.getCookies()
  const appCookie = cookies.find((c) => c.name === appSessionCookieName)

  if (!appCookie || !appCookie.value) {
    // Brutal truth: if this fails, it means your app didn’t set the cookie OR it’s HttpOnly + different domain
    // (domain mismatch) OR you’re not actually landing on the app.
    throw new Error(
      `Login succeeded but could not find cookie "${appSessionCookieName}". ` +
        `Found: ${cookies.map((c) => c.name).join(', ')}`
    )
  }

  // Write JSON artifact for JMeter
  const outDir = path.dirname(outputFile)
  await fs.mkdir(outDir, { recursive: true })

  const payload = {
    createdAt: new Date().toISOString(),
    expectedDomain,
    appSessionCookieName,
    cookie: appCookie,
    // convenience for JMeter "Cookie:" header if you choose header injection instead of Cookie Manager
    cookieHeader: `${appCookie.name}=${appCookie.value}`
  }

  await fs.writeFile(outputFile, JSON.stringify(payload, null, 2), 'utf-8')
  console.log(`Wrote app session cookie to ${outputFile}`)
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
  const emailField = await $('#i0116')
  await emailField.waitForDisplayed({ timeout: 15000 })
  await emailField.setValue(username)
  await (await $('#idSIButton9')).click()

  const passwordField = await $('#i0118')
  await passwordField.waitForDisplayed({ timeout: 15000 })
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
  const emailField = await $('#i0116')
  if (await emailField.isDisplayed()) {
    console.log('Retrying login (email page detected)')
    await emailField.setValue(username)
    await (await $('#idSIButton9')).click()
  }

  const passwordField = await $('#i0118')
  if (await passwordField.isDisplayed()) {
    await passwordField.setValue(password)
    await (await $('#idSIButton9')).click()
  }

  const staySignedIn = await $('#idBtn_Back')
  if (await staySignedIn.isDisplayed()) {
    await staySignedIn.click()
  }
}

async function clickSignInWithRetry(maxRetries = 3) {
  const signInButtonSelector = '#idSIButton9'
  const loginHeaderSelector = '#loginHeader'

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const signInButton = await $(signInButtonSelector)
    await signInButton.waitForDisplayed({ timeout: 10000 })
    await signInButton.waitForEnabled({ timeout: 10000 })
    await signInButton.scrollIntoView()
    await signInButton.moveTo()
    await signInButton.click()
    await browser.pause(2000)

    const loginHeader = await $(loginHeaderSelector)
    if (await loginHeader.isDisplayed()) {
      const headerText = (await loginHeader.getText()).trim()
      if (headerText === 'Enter password') {
        console.warn(`Still on password page (attempt ${attempt}). Retrying...`)
        continue
      }
    }

    const currentUrl = await browser.getUrl()
    if (!currentUrl.includes('login.microsoftonline.com')) return

    console.warn(`Still on login.microsoftonline.com (attempt ${attempt}). Retrying...`)
  }

  throw new Error('Login stuck on password page after multiple retries.')
}

async function clickButtonByText(text) {
  const button = await $(`button=${text}`)
  await button.waitForClickable({ timeout: 10000 })
  await button.click()
}
