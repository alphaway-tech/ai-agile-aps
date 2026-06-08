import { defineConfig, devices } from "@playwright/test";
import path from "path";

/**
 * Playwright config — agile-ai-aps template
 * Adapt BASE_URL, storageState path, và reporter cho project thực tế.
 */

const BASE_URL = process.env.BASE_URL || "http://localhost:3000";

export default defineConfig({
  testDir: "./specs",
  fullyParallel: false,      // set true nếu tests độc lập hoàn toàn
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 1,
  timeout: 30_000,

  reporter: [
    ["list"],
    ["json", { outputFile: "artifacts/report.json" }],
  ],

  use: {
    baseURL: BASE_URL,
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },

  projects: [
    {
      name: "setup",
      testMatch: /global-setup\.ts/,
    },
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        storageState: "testAuthToken.json",
      },
      dependencies: ["setup"],
    },
  ],

  outputDir: "test-results/",

  // Chạy global teardown để cleanup data sau suite
  // globalTeardown: "./global-teardown.ts",
});
