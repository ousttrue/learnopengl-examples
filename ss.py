from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={'width': 400, 'height': 300})
    page.goto('http://localhost:8080/shapes-transform.html')
    page.screenshot(path='docs/shapes-transform.jpg')

    browser.close()
