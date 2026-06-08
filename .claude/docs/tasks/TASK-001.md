## TASK-001

**Status:** Done
**Type:** feature
**Title:** Implement Todo CRUD — store, UI components, filter

**Business Goal:** Cho phép người dùng tạo, xem, toggle và xóa todos theo REQ-1.

**US Reference:** US-001
**Requirement References:** REQ-1.AC1–AC10, CP-1, CP-2
**Design References:** Components > TodoStore, Components > TodoList, Components > FilterBar

**Impacted Files:**
- `src/store/todo.ts` — state management
- `src/components/TodoForm.ts` — form tạo todo
- `src/components/TodoList.ts` — danh sách + filter
- `.claude/docs/design.md` — cập nhật architecture

---

### Approach
Dùng in-memory store (Map) làm data layer đơn giản nhất — không cần DB ở phiên bản đầu. Status là union type `'pending' | 'completed'` để enforce CP-2 ở compile time. Filter là derived state từ store, không lưu riêng.

### Plan
1. Tạo `src/store/todo.ts` — TodoStore class với CRUD + filter methods
2. Tạo `src/components/TodoForm.ts` — validate title, dispatch create event
3. Tạo `src/components/TodoList.ts` — render list + filter bar + delete confirm
4. Update design.md với component architecture

### Acceptance Criteria
- [x] AC1: submit title → saved pending, hiển thị đầu list
- [x] AC2: submit rỗng → validation error, không save
- [x] AC3: list sort by created_at descending
- [x] AC4: click complete pending → status='completed'
- [x] AC5: click complete completed → status='pending'
- [x] AC6: delete → confirm → xóa vĩnh viễn
- [x] AC7: filter Đang làm → chỉ pending + count badge
- [x] AC8: filter Hoàn thành → chỉ completed + count badge
- [x] AC9: filter Tất cả → all todos
- [x] AC10: empty state khi filter rỗng
- [x] CP-1: count badge = số items render
- [x] CP-2: type system enforce 'pending' | 'completed'

### Predicted Impact
**Requirement Impact:** none — REQ-1 đã cover đầy đủ
**Design Impact:** Components section cần thêm TodoStore, TodoForm, TodoList, FilterBar

---

### Implementation Summary
Tạo 3 files: TodoStore (in-memory CRUD), TodoForm (create với validation), TodoList (render + filter). Status dùng TypeScript union type để CP-2 được enforce tại compile time. Filter computed trực tiếp từ store.

### Changed Files
- `src/store/todo.ts` — TodoStore class, Todo type, FilterType
- `src/components/TodoForm.ts` — form component, validation
- `src/components/TodoList.ts` — list render, filter bar, delete confirm

### System Impact Analysis
In-memory store → data mất khi reload page (acceptable cho v1). Không có auth → mọi user thấy cùng 1 list (scope US-001). Filter là UI-only state, không persist.

### Requirement Impact: none
### Design Impact: Components > TodoStore, TodoForm, TodoList, FilterBar (added)
### Lessons Learned: Union type cho status hiệu quả hơn string — bắt lỗi typo tại compile time.

**Git Commit:** see below
**Completed At:** 2026-06-08
