import { test as base, expect } from "@playwright/test";

/**
 * Test fixtures template — agile-ai-aps
 *
 * Thay thế:
 * - `ApiClient` bằng client thực tế của project (Supabase, Axios, Prisma...)
 * - `authenticate()` bằng flow auth thực tế
 * - `cleanupTestData` bằng logic cleanup phù hợp
 */

/** Prefix để identify test data — tránh conflict với data thật */
export const TEST_PREFIX = "[TEST]";

type Fixtures = {
  /** Client có auth để gọi API/DB trực tiếp trong tests */
  apiClient: any; // Thay bằng type thực tế: SupabaseClient, PrismaClient...

  /** Cleanup test data sau mỗi test */
  cleanupTestData: (prefix: string) => Promise<void>;
};

export const test = base.extend<Fixtures>({
  apiClient: async ({}, use) => {
    // TODO: khởi tạo authenticated client
    // Ví dụ Supabase:
    // const client = createClient(SUPABASE_URL, SUPABASE_KEY);
    // await client.auth.signInWithPassword({ email, password });
    // await use(client);

    await use(null); // placeholder
  },

  cleanupTestData: async ({ apiClient }, use) => {
    await use(async (prefix: string) => {
      // TODO: xóa toàn bộ test data có tên bắt đầu bằng prefix
      // Ví dụ:
      // await apiClient.from("bills").delete().ilike("name", `${prefix}%`);
    });
  },
});

export { expect };
