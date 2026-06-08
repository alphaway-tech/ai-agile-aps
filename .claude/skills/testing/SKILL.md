---
description: Gen e2e tests từ requirements.md — coverage audit, extend page objects, viết spec cases
---

# /testing Skill

Skill này đọc `requirements.md`, map từng AC thành BDD test case, viết vào `testing/specs/`, và extend page objects nếu cần.

> **Tech stack:** Mặc định dùng **Playwright** (Web). Xem section "Adapter" để thay bằng Detox (Mobile) hoặc pytest/Supertest (API).

## Subcommands

| Subcommand | Action |
|---|---|
| `/testing coverage` | Audit coverage — liệt kê AC đã có test, thiếu, hoặc skip |
| `/testing gen REQ-N` | Gen test cases cho một REQ cụ thể |
| `/testing gen all` | Gen toàn bộ test cases còn thiếu |
| `/testing run` | Hướng dẫn chạy test suite |

Không có subcommand → chạy `/testing coverage` trước, hỏi user gen REQ nào.

---

## Bước 1 — Đọc requirements đúng cách

```bash
# Lấy danh sách section headers
grep -n "^###\|^##" .claude/docs/requirements.md

# Đọc 1 REQ cụ thể (targeted)
Read(.claude/docs/requirements.md, offset=X, limit=35)
```

Mỗi AC dạng `WHEN ... THEN ...` → map 1:1 với 1 test case.

---

## Bước 2 — Audit coverage

```bash
# Xem test nào đang cover REQ nào
grep -rn "REQ-" testing/specs/

# Đếm test per spec file
grep -c "test(" testing/specs/*.spec.ts 2>/dev/null || \
grep -c "def test_" testing/specs/*.py 2>/dev/null

# Xem page object methods
grep -n "async \|def " testing/pages/*.ts testing/pages/*.py 2>/dev/null
```

**Tag bắt buộc** — mỗi test phải có tag `// REQ-N.ACx` ngay trên `test(`:
```typescript
// REQ-5.AC1 — equal split rounds up to 1000
test("chia đều làm tròn 1000", async ({ page }) => { ... });
```

---

## Bước 3 — Quy tắc skip

Những AC **không automate** — ghi rõ lý do trong coverage report:

| Lý do | Ví dụ |
|---|---|
| AI/LLM non-deterministic | Chat response, AI suggestions |
| File upload phức tạp | Proof image, avatar upload |
| Cần service_role key | RLS bypass tests |
| Viewport/responsive fragile | Mobile breakpoint tests |
| External payment gateway | Actual payment processing |

Ghi vào matrix: `⏭ skip — [lý do]`

---

## Bước 4 — Template test case (Playwright)

```typescript
// REQ-N.ACx — [mô tả ngắn AC]
test("[tên test mô tả behavior]", async ({ page, apiClient }) => {
  // GIVEN: setup state
  // WHEN: user action  
  // THEN: assertion
});
```

### Pattern: Setup data qua API (nhanh hơn UI 10x)

```typescript
test.beforeEach(async ({ apiClient }) => {
  // Insert trực tiếp qua API/DB — không mở UI để create
  testEntityId = await apiClient.create({ name: `${TEST_PREFIX} ...` });
});
```

### Pattern: Test unauthenticated

```typescript
test("public page không redirect login", async ({ browser }) => {
  const ctx = await browser.newContext({ storageState: undefined });
  const page = await ctx.newPage();
  await page.goto("/public-route");
  await expect(page).not.toHaveURL(/login/);
  await ctx.close();
});
```

### Pattern: Assert DB state (invariants)

```typescript
test("CP-1: tổng share_amount = bill.amount", async ({ apiClient }) => {
  const members = await apiClient.getMembers(billId);
  const total = members.reduce((s, m) => s + m.share_amount, 0);
  expect(total).toBe(expectedAmount);
});
```

---

## Bước 5 — Extend page objects khi thiếu method

```bash
# Kiểm tra method đã có chưa
grep -n "async " testing/pages/*.ts
```

Nếu thiếu → **edit page object trước**, rồi mới viết test dùng method đó.

**Convention page object:**
```typescript
export class [FeatureName]Page {
  constructor(readonly page: Page) {}

  async goto() { ... }
  async [action]([params]): Promise<void> { ... }
  async get[State](): Promise<[type]> { ... }
}
```

---

## Bước 6 — Coverage plan template

```markdown
### REQ-N: [Tên]

| AC | Status | Test |
|----|--------|------|
| AC1 — [mô tả] | ✅ covered | [tên test] |
| AC2 — [mô tả] | ⬜ gap | Cần gen |
| AC3 — [mô tả] | ⏭ skip | [lý do] |
```

---

## Bước 7 — Thứ tự gen (ưu tiên ROI cao → thấp)

1. Core business logic (tính toán, validation)
2. CRUD flows chính
3. Auth / permission boundaries
4. Error / edge cases
5. UI state / loading / empty states
6. Secondary flows

---

## Bước 8 — Quy trình gen 1 REQ

```
1. Read ACs của REQ từ requirements.md
2. grep -rn "REQ-N" testing/specs/ → xem AC nào đã cover
3. Xác định page object methods còn thiếu → edit page object
4. Viết test cases mới vào spec file tương ứng
5. Mỗi test có comment // REQ-N.ACx
6. Báo user chạy: cd testing && [test command]
```

---

## Adapter — Thay đổi test framework

### Web: Playwright (default)
```bash
npx playwright test [spec].spec.ts --grep "REQ-N"
npx playwright test  # full suite
```

### Mobile: Detox (React Native)
```bash
# Thay spec format: describe/it thay vì test.describe/test
# Page objects: ElementRef thay vì Locator
detox test --testPathPattern="REQ-N"
```

### API: pytest
```bash
# Spec format: def test_[name](client):
# Page objects: APIClient class thay vì Page class
pytest testing/specs/ -k "REQ_N" -v
```

### Khi adapt: chỉ cần thay đổi:
1. Spec file format (test runner syntax)
2. Page object base (browser locators → native/http)
3. Fixture setup/teardown (auth, DB cleanup)
4. Run commands trong SKILL.md này

---

## Test Gotchas

Patterns phát hiện qua debug — cập nhật tự do sau mỗi QA cycle.

Format: **Triệu chứng** → **Root cause** → **Fix**

*(Thêm gotchas của project này vào đây khi gặp)*

---

## File mapping — REQ → spec file

*(Điền khi project được init — map từng REQ sang spec file tương ứng)*

| REQ | Spec file |
|---|---|
| REQ-1 | `[feature].spec.ts` |
