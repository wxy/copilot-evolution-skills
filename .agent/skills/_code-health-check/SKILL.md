---
name: code-health-check
description: Perform code quality checks before commit. Validates code standards, security, architectural consistency. Runs TypeScript compilation, linting, test coverage verification.
---

# _code-health-check

## Overview

Systematic quality verification before code commits. Prevents errors and maintains code health.

**When to use**: After editing files, before sending PR, before committing code

**Process**: 5 automated checks catching most issues early

---

## Pre-commit Checklist

### 1. TypeScript Errors (IDE & Compilation)

```bash
# Check VSCode problems panel (Cmd+Shift+M)
# Look for red errors (not just warnings)

# Command-line verification
npx tsc --noEmit
```

**Action**:
- ❌ Red errors → Must fix before commit
- ⚠️ Yellow warnings → Review, fix if serious
- ✅ Zero errors → Clear to continue

### 2. Linting & Code Style

```bash
# Run linter
npm run lint

# Auto-fix common issues
npm run lint:fix
```

**Common issues**:
- Unused imports/variables
- Inconsistent formatting
- Missing semicolons
- Line too long

### 3. Build Verification

```bash
# Build to catch compilation errors
npm run build

# Verify build succeeds with zero errors
# Check build/ or dist/ output
```

**Must pass**: No build errors

### 4. Test Suite

```bash
# Run all tests
npm run test:run

# Coverage report
npm run test:coverage

# Target: ≥70% line coverage
```

**Check**:
- [ ] All tests pass
- [ ] Coverage ≥70%
- [ ] New code has tests

### 5. Pre-push Hook (if configured)

```bash
# Comprehensive check before push
npm run pre-push

# Typically includes:
# - TypeScript check
# - Linting
# - Tests
# - Build
```

---

## Quick Workflow

```bash
# 1. Edit files
# ... (editing done)

# 2. Fix issues
npm run lint:fix        # Auto-fix style issues
npm run build           # Check compilation
npm run test:run        # Run tests
npm run pre-push        # Final check

# 3. Review output
# - If all pass → Ready for commit
# - If fails → Fix and repeat step 2
```

---

## Error Categories & Fixes

| Error Type | Detection | Fix |
|-----------|-----------|-----|
| Import not found | IDE/tsc | Add missing import or remove unused |
| Type mismatch | IDE/tsc | Correct type or cast appropriately |
| Unused variable | Lint | Remove or use _prefix if intentional |
| Test failing | npm test | Debug and fix test or code |
| Coverage gap | Coverage report | Add tests for new code |

---

## Common Issues

### Issue: "Cannot find module"
```bash
# Solution: Verify import path
# 1. Check file exists at path
# 2. Verify correct relative path
# 3. Update import path
```

### Issue: "Type expectation"
```bash
# Solution: Use _typescript-type-safety skill
# 1. Review type definition
# 2. Provide all required fields
# 3. Use correct enum values
```

### Issue: Tests failing
```bash
# Solution: Debug test failure
npm run test:run -- --reporter=verbose
# Review actual vs expected
# Fix code or test as needed
```

### Issue: Build fails
```bash
# Solution: Check build output
npm run build 2>&1 | head -20
# Address first error
# Retry build
```

---

## Checklist Before Commit

```markdown
## Pre-commit Verification

- [ ] VSCode Problems panel: 0 errors
- [ ] `npm run lint`: 0 errors
- [ ] `npm run build`: Success
- [ ] `npm run test:run`: All pass
- [ ] Coverage report ≥70%
- [ ] `npm run pre-push`: All pass (if available)
- [ ] Commit message formatted (_git-commit skill)
```

---

## Best Practices

1. **Run checks frequently** during development, not just before commit
2. **Fix issues immediately** - easier when context is fresh
3. **Use IDE warnings** as early signals
4. **Automate where possible** - pre-commit hooks, lint-staged
5. **Review build output** - don't just check exit code

---

## Related Skills

- **_git-commit**: Ensure commit message format
- **_typescript-type-safety**: Fix type-related errors
- **_release-process**: Quality gates for releases
