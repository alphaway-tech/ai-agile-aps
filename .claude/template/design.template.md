# Design Document: [Tên project/feature]

## Overview

[Mô tả ngắn về thiết kế, các mục tiêu chính.]

**Requirement References:** [Danh sách REQ-N liên quan tổng thể]

---

## Architecture

```
[Diagram dạng text thể hiện cấu trúc hệ thống]
```

### Request Flow

```
[Mô tả luồng request từ client đến server và ngược lại]
```

---

## Components and Interfaces

### [Component 1]: [Tên]

**Requirement References:** REQ-N, REQ-M
**File:** `path/to/file.ts`

[Mô tả chức năng, interface, props/params quan trọng]

```typescript
// Ví dụ interface hoặc function signature
```

---

### [Component 2]: [Tên]

**Requirement References:** REQ-N
**File:** `path/to/file.ts`

[Mô tả]

---

## Data Models

### [Model 1]

**Requirement References:** REQ-N
**Table:** `table_name`

| Field | Type | Notes |
|---|---|---|
| `id` | uuid | PK |
| `field` | type | mô tả |

---

## Key Business Logic

### [Logic 1]: [Tên]

**Requirement References:** REQ-N.X, REQ-N.Y

```typescript
// Pseudo-code hoặc actual implementation
```

---

## Correctness Properties

*Properties là invariants phải đúng trong mọi execution.*

### Property 1: [Tên]

*For any* [điều kiện], [component] SHALL [invariant].

**Validates:** Requirements N.X | **Component:** [tên component]

---

## Error Handling

### Standard Error Response

```json
{ "error": "<message>" }
```

### HTTP Status Reference

| Status | Condition |
|---|---|
| 4xx | ... |

---

## Testing Strategy

**Requirement References:** Tất cả requirements

[Mô tả approach, framework, các test case quan trọng]

---
