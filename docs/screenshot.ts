const pw = require('playwright');
const examples = require('./src/components/HomepageFeatures/examples.json');

(async () => {
  const browser = await pw.chromium.launch(); // or 'chromium', 'firefox'
  const context = await browser.newContext();
  const page = await context.newPage();
  // page.setDefaultTimeout(30000 * 30);
  page.setViewportSize({ "width": 400, "height": 300 });

  let i=1;
  for (const group of examples) {
    for (const article of group.list) {
      for (const name of article.sections) {
        const url = `http://localhost:3000/learnopengl-examples/wasm/${name}.html`
        console.log(i, url);
        await page.goto(url);
        await page.waitForLoadState('networkidle')
        await page.screenshot({ path: `static/wasm/${name}.jpg` });
        ++i;
      }
    }
  }

  await browser.close();
})();
