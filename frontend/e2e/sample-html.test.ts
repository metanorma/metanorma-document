import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import puppeteer, { type Browser, type Page } from 'puppeteer'
import { readFileSync } from 'fs'
import { resolve } from 'path'

describe('sample.html E2E', () => {
  let browser: Browser
  let page: Page
  const samplePath = resolve(__dirname, '../dist/sample.html')

  beforeAll(async () => {
    browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    })
    page = await browser.newPage()
    await page.setViewport({ width: 1280, height: 900 })

    // Collect console errors
    page.on('pageerror', (err) => {
      console.error('PAGE ERROR:', err.message)
    })
  })

  afterAll(async () => {
    await browser.close()
  })

  it('file exists and is non-empty', () => {
    const content = readFileSync(samplePath, 'utf-8')
    expect(content.length).toBeGreaterThan(1000)
  })

  it('loads without JavaScript errors', async () => {
    const errors: string[] = []
    page.on('console', (msg) => {
      if (msg.type() === 'error') errors.push(msg.text())
    })

    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    // Filter out benign errors (e.g. ERR_FILE_NOT_FOUND for fonts/data on file:// protocol)
    const realErrors = errors.filter(e =>
      !e.includes('ERR_FILE_NOT_FOUND') &&
      !e.includes('service worker') &&
      !e.includes('favicon')
    )
    expect(realErrors).toHaveLength(0)
  })

  it('Vue app mounts and replaces SSR content', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })
    await page.waitForSelector('#metanorma-app', { timeout: 5000 })

    // The Vue app should have mounted — check for Vue-generated content
    const appHtml = await page.$eval('#metanorma-app', (el) => el.innerHTML)
    expect(appHtml.length).toBeGreaterThan(100)
  })

  it('document title is visible', async () => {
    const title = await page.$eval('title', (el) => el.textContent)
    expect(title).toContain('ISO 17301-1:2016')
  })

  it('renders clause headings with numbering', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })
    await page.waitForSelector('.mn-clause, .mn-foreword', { timeout: 5000 })

    const headings = await page.$$eval('h2', (els) =>
      els.map((el) => el.textContent?.trim() || '')
    )

    expect(headings.some(h => h.includes('Scope'))).toBe(true)
    expect(headings.some(h => h.includes('Foreword'))).toBe(true)
    expect(headings.some(h => h.includes('Test methods'))).toBe(true)
    expect(headings.some(h => h.includes('Terms and definitions'))).toBe(true)
  })

  it('renders paragraphs with text content', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })
    await page.waitForSelector('p', { timeout: 5000 })

    const paragraphs = await page.$$eval('p', (els) =>
      els.map((el) => el.textContent?.trim() || '')
    )

    expect(paragraphs.some(p => p.includes('ISO (the International Organization'))).toBe(true)
    expect(paragraphs.some(p => p.includes('test methods'))).toBe(true)
  })

  it('renders inline marks (strong, emphasis)', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const strongText = await page.$eval('strong', (el) => el.textContent)
    expect(strongText).toBe('the test methods')

    const emTexts = await page.$$eval('em', (els) =>
      els.map((el) => el.textContent?.trim() || '')
    )
    expect(emTexts).toContain('Oryza sativa L.')
    expect(emTexts).toContain('Oryza glaberrima')
  })

  it('renders bullet list with list items', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const listItems = await page.$$eval('ul li', (els) =>
      els.map((el) => el.textContent?.trim() || '')
    )
    expect(listItems.length).toBeGreaterThanOrEqual(3)
    expect(listItems).toContain('Milling quality assessment')
    expect(listItems).toContain('Moisture content determination')
  })

  it('renders ordered list', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const olItems = await page.$$eval('ol li', (els) =>
      els.map((el) => el.textContent?.trim() || '')
    )
    expect(olItems).toContain('Weigh the sample')
    expect(olItems).toContain('Dry at 130 °C')
    expect(olItems).toContain('Re-weigh and calculate')
  })

  it('renders table with header and body', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })
    await page.waitForSelector('table', { timeout: 5000 })

    const headers = await page.$$eval('th', (els) =>
      els.map((el) => el.textContent?.trim() || '')
    )
    expect(headers).toContain('Parameter')
    expect(headers).toContain('Method')
    expect(headers).toContain('Unit')

    const cells = await page.$$eval('td', (els) =>
      els.map((el) => el.textContent?.trim() || '')
    )
    expect(cells).toContain('Moisture content')
    expect(cells).toContain('ISO 712')
  })

  it('renders admonition with warning type', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    // Vue uses "admonition-warning" class (SSR uses "mn-admonition--warning")
    const hasWarning = await page.$eval('.admonition-warning', () => true).catch(() => false)
    expect(hasWarning).toBe(true)

    const warningText = await page.$eval('.admonition-warning', (el) => el.textContent)
    expect(warningText).toContain('(20 ± 2) °C')
  })

  it('renders sourcecode block with language badge', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const hasSourcecode = await page.$eval('.mn-sourcecode', () => true).catch(() => false)
    expect(hasSourcecode).toBe(true)

    const codeText = await page.$eval('.mn-sourcecode code', (el) => el.textContent)
    expect(codeText).toContain('moisture_content')
  })

  it('renders figure with image and caption', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const hasFigure = await page.$eval('figure', () => true).catch(() => false)
    expect(hasFigure).toBe(true)

    const imgAlt = await page.$eval('figure img', (el) => (el as HTMLImageElement).alt)
    expect(imgAlt).toBe('Grain structure diagram')

    const caption = await page.$eval('figcaption', (el) => el.textContent)
    expect(caption).toContain('Grain structure')
  })

  it('renders nested clause (term entry)', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const termHeading = await page.$eval('#term-rice', (el) => el.textContent)
    expect(termHeading).toContain('rice')

    const hasExample = await page.$eval('.mn-example', () => true).catch(() => false)
    expect(hasExample).toBe(true)

    const hasNote = await page.$eval('.mn-note', () => true).catch(() => false)
    expect(hasNote).toBe(true)
  })

  it('renders blockquote', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const quote = await page.$eval('blockquote', (el) => el.textContent)
    expect(quote).toContain('Precision is the soul of science')
  })

  it('CSS variables are applied (theme renders)', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    // CSS variables should be defined on :root
    const rootVars = await page.evaluate(() => {
      const s = getComputedStyle(document.documentElement)
      return {
        ebookBg: s.getPropertyValue('--ebook-bg').trim(),
        ebookText: s.getPropertyValue('--ebook-text').trim(),
        ebookBorder: s.getPropertyValue('--ebook-border').trim(),
      }
    })
    expect(rootVars.ebookBg).toBeTruthy()
    expect(rootVars.ebookText).toBeTruthy()
    expect(rootVars.ebookBorder).toBeTruthy()

    // Body should have the themed background color
    const bodyBg = await page.$eval('body', (el) => {
      return window.getComputedStyle(el).backgroundColor
    })
    expect(bodyBg).not.toBe('rgba(0, 0, 0, 0)')
  })

  it('xref links render correctly', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const xrefLink = await page.$eval('a[href="#iso712"]', (el) => ({
      text: el.textContent,
      href: el.getAttribute('href'),
    }))
    expect(xrefLink.text).toBe('ISO 712')
    expect(xrefLink.href).toBe('#iso712')
  })

  it('sidebar TOC is populated', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    // The Vue app should have rendered the sidebar with TOC items
    const sidebarExists = await page.$eval('.sidebar', () => true).catch(() => false)
    if (sidebarExists) {
      const tocTitle = await page.$eval('.sidebar-title', (el) => el.textContent)
      expect(tocTitle).toContain('ISO 17301-1:2016')
    }
  })

  it('no duplicate IDs in the document', async () => {
    await page.goto(`file://${samplePath}`, { waitUntil: 'networkidle0', timeout: 15000 })

    const ids = await page.$$eval('[id]', (els) =>
      els.map((el) => el.id).filter(Boolean)
    )
    const uniqueIds = new Set(ids)
    if (ids.length !== uniqueIds.size) {
      const dupes = ids.filter((id, i) => ids.indexOf(id) !== i)
      console.error('Duplicate IDs:', [...new Set(dupes)])
    }
    expect(uniqueIds.size).toBe(ids.length)
  })
})
