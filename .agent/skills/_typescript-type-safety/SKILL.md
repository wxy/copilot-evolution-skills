---
name: typescript-type-safety
description: Enforce TypeScript type safety guidelines. Ensures proper typing, prevents type-related runtime errors. Focuses on mock data creation, enum handling, and complex type initialization.
---

# _typescript-type-safety

## Overview

Ensures type-safe code in TypeScript projects. Prevents runtime errors through strict type checking, proper enum usage, and correct mock data creation.

**When to use**: Creating test mocks, handling enums, initializing complex types

**Key principle**: Never use `as any` or empty objects `{}` - always provide complete type initialization

---

## Common Type Errors & Solutions

### Error 1: Missing Required Properties

```typescript
// ❌ Wrong: Empty object
const user: UserProfile = {} as UserProfile

// ✅ Correct: All required fields
const user: UserProfile = {
  id: '123',
  name: 'John',
  email: 'john@example.com'
}
```

**Fix**: Read interface definition, identify all required fields (no `?`), provide values for each.

### Error 2: Invalid Enum Values

```typescript
// ❌ Wrong: String literal without enum
status: 'pending'  // Not in Status enum

// ✅ Correct: Use actual enum value
import { Status } from './types'
status: Status.PENDING
```

**Fix**: 
1. Find enum definition
2. List all valid values
3. Use actual enum value, not string

### Error 3: Incomplete Nested Objects

```typescript
// ❌ Wrong
const config: AppConfig = {
  databases: {}  // Missing all required keys
}

// ✅ Correct
const config: AppConfig = {
  databases: {
    primary: { host: 'localhost', port: 5432 },
    cache: { host: 'localhost', port: 6379 }
  }
}
```

---

## Mock Factory Pattern

Create reusable factory functions for complex types:

```typescript
// ✅ Good: Type-safe factory
function createMockUser(
  overrides: Partial<User> = {}
): User {
  return {
    id: `user-${Math.random()}`,
    name: 'Test User',
    email: 'test@example.com',
    status: Status.ACTIVE,
    ...overrides
  }
}

// Usage with partial overrides
const user = createMockUser({ name: 'Custom Name' })
```

**Benefits**:
- DRY (Don't Repeat Yourself)
- Single source of truth
- Type-safe
- Easy to maintain

### Nested Type Factories

```typescript
// For complex nested types
function createMockConfig(
  overrides: Partial<Config> = {}
): Config {
  return {
    database: createMockDatabaseConfig(overrides.database),
    cache: createMockCacheConfig(overrides.cache),
    ...overrides
  }
}

function createMockDatabaseConfig(
  overrides: Partial<DatabaseConfig> = {}
): DatabaseConfig {
  return {
    host: 'localhost',
    port: 5432,
    name: 'testdb',
    ...overrides
  }
}
```

---

## Enum Patterns

### Initialize All Enum Keys

```typescript
// When type requires all enum values
export interface Distribution {
  [Category.TECH]: number
  [Category.SCIENCE]: number
  [Category.ARTS]: number
}

// ✅ Correct: Initialize all keys
const dist: Distribution = {
  [Category.TECH]: 0.5,
  [Category.SCIENCE]: 0.3,
  [Category.ARTS]: 0.2
}

// ❌ Wrong: Partial initialization
const dist: Distribution = {
  [Category.TECH]: 0.5
}
```

### Enum Value Validation

```typescript
// Before using enum values, verify definition:

export enum Status {
  PENDING = 'pending',    // ✅ Valid
  ACTIVE = 'active',
  INACTIVE = 'inactive'
  // ❌ 'archived' not defined
}

// Use enum directly
const status = Status.PENDING  // ✅
const status = 'pending' as Status  // ✅ (type assertion safe)
const status = 'archived'  // ❌ Compile error
```

---

## Verification Process

### 1. Read Type Definition

```bash
# Identify all required fields
# Check field types (especially enums)
# Note nested types that need initialization
```

### 2. Create Checklist

```markdown
- [ ] Field1: type (required)
- [ ] Field2: enum type (valid values listed)
- [ ] Field3: object type (nested fields initialized)
```

### 3. Implement with Factory

```typescript
function createMock(overrides = {}): Type {
  return {
    // all required fields with valid values
    ...overrides
  }
}
```

### 4. Verify with Type Checker

```bash
# Run TypeScript compiler check
npm run build

# Or use IDE to verify zero errors
```

---

## Quick Checklist

Before declaring a typed variable:
- [ ] All required fields assigned
- [ ] All enum fields use valid values
- [ ] Nested types fully initialized
- [ ] No `any` type assertions
- [ ] No empty `{}` objects without type
- [ ] TypeScript compiler shows no errors

---

## Common Pitfalls

| Issue | Check |
|-------|-------|
| Using `Partial<T>` where `T` required | Provide defaults or validate at use site |
| Enum string vs enum value | Import enum, use enum value directly |
| Missing nested fields | Create factory functions for nested types |
| Type assertion with `as any` | Remove assertion, let TypeScript guide you |
| Copy-paste wrong field name | Reference type definition directly |

---

## Best Practices

1. **Create factory functions** for types with 3+ required fields
2. **Use Partial<Type>** for optional overrides in factory params
3. **Import enums** directly - don't hardcode strings
4. **Document expectations** with JSDoc for factories
5. **Run type checker** after major changes

---

## Related Skills

- **_code-health-check**: Validates type safety as part of pre-commit checks
- **run_in_terminal**: Execute `npm run build` or `tsc --noEmit` for verification
