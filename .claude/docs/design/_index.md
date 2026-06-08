# Design Overview — Todo Manager

## System Architecture

```
Browser
  └── TodoList (component) ← FilterType state
       ├── TodoForm (component) → createTodo()
       └── TodoItem × N → toggleTodo() / deleteTodo()

Data Layer:
  TodoStore (in-memory Map)
    ├── create(title, desc?) → Todo | throws
    ├── toggleStatus(id) → Todo
    ├── delete(id) → void
    ├── list(filter) → Todo[] sorted by created_at DESC
    └── count(filter) → number
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Data | In-memory Map (v1) |
| Language | TypeScript |
| Testing | Playwright / Jest |

## Out of Scope (v1)

- Persistent storage (localStorage/DB) → v2
- Auth / multi-user → US-002
- Due date / reminder → US-003

---

## REQ Design Files

| REQ | File | Last updated |
|-----|------|-------------|
| REQ-1 | [REQ-1.md](REQ-1.md) | TASK-001 (2026-06-08) |
