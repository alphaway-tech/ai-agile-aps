import { chromium, FullConfig } from "@playwright/test";

/**
 * Global setup — agile-ai-aps template
 *
 * Chạy 1 lần trước toàn bộ test suite.
 * Mục đích: authenticate và lưu storageState vào testAuthToken.json
 * để các tests không cần login lại.
 *
 * Adapt `authenticate()` cho auth flow thực tế của project.
 */

async function globalSetup(config: FullConfig) {
  const { baseURL } = config.projects[0].use;
  const browser = await chromium.launch();
  const page = await browser.newPage();

  // TODO: implement auth flow
  // Ví dụ 1 — UI login:
  // await page.goto(`${baseURL}/login`);
  // await page.fill('[name=email]', process.env.TEST_EMAIL!);
  // await page.fill('[name=password]', process.env.TEST_PASSWORD!);
  // await page.click('[type=submit]');
  // await page.waitForURL(`${baseURL}/dashboard`);

  // Ví dụ 2 — Set token trực tiếp:
  // await page.goto(baseURL!);
  // await page.evaluate((token) => localStorage.setItem('auth_token', token), process.env.TEST_TOKEN!);

  // Lưu session state
  await page.context().storageState({ path: "testAuthToken.json" });
  await browser.close();
}

export default globalSetup;
