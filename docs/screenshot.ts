import { chromium } from '@playwright/test';
import { list as examples } from './src/components/HomepageFeatures/list';
import fs from 'node:fs';

let sum = 0;
for (const group of examples) {
  for (const article of group.list) {
    for (const name of article.sections) {
      ++sum;
    }
  }
}

let i = 1;
for (const group of examples) {
  for (const article of group.list) {
    for (const name of article.sections) {
      const url = `http://localhost:3000/learnopengl-examples/wasm/${name}.html`
      console.log(`[${i}/${sum}]`, url);
      ++i;

      const browser = await chromium.launch(); // or 'chromium', 'firefox'
      const context = await browser.newContext();
      const page = await context.newPage();
      page.setViewportSize({ "width": 300, "height": 157 });

      try {
        await page.goto(url);
        await page.waitForLoadState('networkidle')
        await page.screenshot({ path: `static/wasm/${name}.jpg` });
        await browser.close();
      } catch (ex) {
        console.error(ex);
      }

      // inject html to ogp
      const path = `static/wasm/${name}.html`
      if (fs.existsSync(path)) {
        let src = fs.readFileSync(path, 'utf8');
        fs.writeFileSync(path, src.replace('<meta charset=utf-8>', `<meta charset=utf-8>
<meta property="og:title" content="${article.title} ${name}">
<meta property="og:type" content="website">
<meta property="og:url" content="https://ousttrue.github.io/rowmath/wasm/${name}.html">
<meta property="og:image" content="https://ousttrue.github.io/rowmath/wasm/${name}.jpg">
<meta property="og:site_name" content="rowmath wasm examples">
<meta property="og:description" content="${article.title} ${name}">
`));
      }
    }
  }
}

