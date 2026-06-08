# Design — REQ-1: Todo CRUD
<!-- Last updated: TASK-001 (2026-06-08) -->

## Components

### TodoStore (`src/store/todo.ts`)

- In-memory `Map<string, Todo>` — data bị mất khi reload (acceptable v1)
- `Status` là union type `'pending' | 'completed'` — CP-2 enforced at compile time
- `list()` always sort descending by `created_at` — AC3
- `create()` throws nếu title rỗng — caller bắt để show validation error

### TodoForm (`src/components/TodoForm.ts`)

- `createTodo(title, desc?)` → `CreateResult { success, error? }`
- Trả `{ success: false, error: 'Tiêu đề không được để trống' }` khi title rỗng — AC2
- Wrap store.create() để caller không cần try/catch

### TodoList (`src/components/TodoList.ts`)

- `getList(filter)` → `{ items, count, filter, empty }` — count = items.length (CP-1)
- `empty: true` khi filter không match todo nào — AC10
- `toggleTodo(id)` — AC4, AC5
- `deleteTodo(id)` — AC6 (UI phải confirm trước khi gọi)

---

## Data Types

```typescript
interface Todo {
  id: string;         // auto-increment string
  title: string;      // required, trimmed
  description?: string;
  status: 'pending' | 'completed';  // CP-2
  created_at: number; // Date.now() timestamp
}
```

---

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| In-memory store (Map) | No backend needed for v1 — simplest path to meet REQ-1 |
| Status as union type | CP-2: TypeScript prevents invalid states at compile time |
| count = items.length | CP-1: single source of truth, no separate counter variable |
| Sorted in store.list() | AC3: list always sorted, caller never needs to sort |
| createTodo wraps throws | Caller gets typed Result, no try/catch at component level |
