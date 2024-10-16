import { chromium } from '@playwright/test';
import {
  CATEGORIES,
} from './src/data';
import fs from 'node:fs';
import config from './vite.config.ts';

const host = 'http://localhost:5173';
const dst = 'public/';

function resolve(src: string): string {
  if (config.base) {
    return config.base + src;
  }
  else {
    return src;
  }
}

let sum = 0;
for (const category of CATEGORIES) {
  for (const article of category.articles) {
    sum += article.samples.length;
  }
}

let i = 1;
for (const category of CATEGORIES) {
  for (const article of category.articles) {
    for (const sample of article.samples) {
      const name = typeof sample == 'string' ? sample : sample[0];
      const url = host + resolve(`wasm/${name}.html`)
      console.log(`[${i}/${sum}]`, url);
      ++i;

      const browser = await chromium.launch(); // or 'chromium', 'firefox'
      const context = await browser.newContext();
      const page = await context.newPage();
      page.setViewportSize({ "width": 300, "height": 157 });

      try {
        await page.goto(url);
        await page.waitForLoadState('networkidle')
        await page.screenshot({ path: `${dst}/wasm/${name}.jpg` });
        await browser.close();
      } catch (ex) {
        console.error(ex);
      }

      // inject html to ogp
      const path = `${dst}/wasm/${name}.html`
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

process.exit(0)
