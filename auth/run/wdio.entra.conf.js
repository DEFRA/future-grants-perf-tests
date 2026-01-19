import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Load environment variables from .env file manually
try {
  const envPath = path.join(__dirname, '.env')
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8')
    envContent.split('\n').forEach((line) => {
      const trimmedLine = line.trim()
      if (trimmedLine && !trimmedLine.startsWith('#')) {
        const [key, ...valueParts] = trimmedLine.split('=')
        if (key && valueParts.length > 0) {
          const value = valueParts.join('=').trim().replace(/^["']|["']$/g, '')
          if (!process.env[key]) {
            process.env[key] = value
          }
        }
      }
    })
    console.log('✓ Loaded .env file')
  } else {
    console.warn('⚠ No .env file found. Make sure to set environment variables.')
  }
} catch (error) {
  console.warn('Could not load .env file:', error.message)
}

const debug = process.env.DEBUG === 'true'

export const config = {
  runner: 'local',

  // Specs to run - only the Entra ID login dump spec
  specs: ['./test/specs/entra-login-dump.e2e.js'],

  exclude: [],

  maxInstances: 1,

  capabilities: [
    {
      maxInstances: 1,
      browserName: 'chrome',
      'goog:chromeOptions': {
        args: debug
          ? [
              '--disable-infobars',
              '--window-size=1920,1080'
            ]
          : [
              '--headless',
              '--no-sandbox',
              '--disable-dev-shm-usage',
              '--disable-infobars',
              '--disable-gpu',
              '--window-size=1920,1080',
              '--enable-features=NetworkService,NetworkServiceInProcess',
              '--password-store=basic',
              '--use-mock-keychain',
              '--dns-prefetch-disable',
              '--disable-background-networking',
              '--disable-remote-fonts',
              '--ignore-certificate-errors'
            ]
      }
    }
  ],

  logLevel: debug ? 'debug' : 'info',
  bail: 1,
  waitforTimeout: 15000,
  waitforInterval: 200,
  connectionRetryTimeout: 120000,
  connectionRetryCount: 3,

  framework: 'mocha',

  reporters: ['spec'],

  mochaOpts: {
    ui: 'bdd',
    timeout: debug ? 3600000 : 120000 // 1 hour for debug, 2 minutes for normal
  },

  /**
   * Hook: runs after test completes
   */
  afterTest: async function (test, context, { error, result, duration, passed, retries }) {
    if (error) {
      console.error('Test failed:', error.message)
      // Take screenshot on failure
      try {
        await browser.takeScreenshot()
      } catch (e) {
        console.error('Could not take screenshot:', e.message)
      }
    }
  },

  /**
   * Hook: runs before test starts
   */
  beforeTest: function (test, context) {
    console.log(`\n${'='.repeat(80)}`)
    console.log(`Starting: ${test.title}`)
    console.log('='.repeat(80))
  }
}
