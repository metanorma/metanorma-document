const puppeteer = require('puppeteer');
const path = require('path');

async function main() {
  const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
  const page = await browser.newPage();

  const errors = [];
  page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
  page.on('pageerror', err => errors.push('PAGE: ' + err.message));

  const samplePath = path.resolve('dist/sample.html');
  await page.goto('file://' + samplePath, { waitUntil: 'networkidle0', timeout: 15000 });
  await page.waitForSelector('#metanorma-app', { timeout: 5000 });
  await new Promise(r => setTimeout(r, 2000));

  console.log('=== Console Errors ===');
  errors.forEach(e => console.log(e));

  console.log('\n=== Admonition classes ===');
  const admonitions = await page.$$eval('[class*="admonition"]', function(els) {
    return els.map(function(el) { return { tag: el.tagName, cls: el.className.substring(0, 100) }; });
  });
  admonitions.forEach(function(a) { console.log(JSON.stringify(a)); });

  console.log('\n=== Body computed styles ===');
  const bodyStyles = await page.evaluate(function() {
    var s = getComputedStyle(document.body);
    return { color: s.color, bg: s.backgroundColor };
  });
  console.log(JSON.stringify(bodyStyles));

  console.log('\n=== Root CSS vars ===');
  const rootVars = await page.evaluate(function() {
    var s = getComputedStyle(document.documentElement);
    return { ebookBg: s.getPropertyValue('--ebook-bg').trim(), ebookText: s.getPropertyValue('--ebook-text').trim() };
  });
  console.log(JSON.stringify(rootVars));

  console.log('\n=== html class ===');
  const htmlClass = await page.evaluate(function() { return document.documentElement.className; });
  console.log(htmlClass);

  await browser.close();
}
main().catch(console.error);
