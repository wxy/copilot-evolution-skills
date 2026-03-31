---
name: release-process
description: Complete release workflow for project versioning. Covers branch creation, testing validation, documentation updates, PR creation via skills, and GitHub Release creation. Emphasizes stability through branch isolation strategy.
---

# _release-process

## Overview

Manages the complete release process from pre-release preparation through GitHub Release creation. Uses branch isolation to keep master stable.

**When to use**: Version releases, feature launches, bug fix releases

**Related skills**: `_git-commit` (formatting commits), `_pr-creator` (PR automation)

---

## Release Flow (10 Steps)

### Prerequisites

- ✅ All features complete in master
- ✅ Code reviewed and approved
- ✅ Tests passing, no compilation errors
- ✅ Target version decided (major/minor/patch)

### Step 0: Pre-release Validation (master branch)

```bash
git checkout master
git pull origin master
git status  # Should show clean working tree
```

**Checklist**:
- [ ] On master branch
- [ ] Working tree clean
- [ ] Local master synced with remote

**Why**: Ensures master is stable baseline for release branch

---

### Step 1: Create Release Branch

```bash
git checkout -b release/v<VERSION>
git branch  # Verify creation
```

**Convention**: `release/v<VERSION>` (semantic versioning)

**Why**: Isolates all release work, keeps master clean

---

### Step 2: Pre-release Cleanup (on release branch)

```bash
# Clean old build artifacts and caches
rm -rf .plasmo build/ coverage/
rm -rf dist/ out/

# Verify .gitignore is correct
git status --short
```

**Checklist**:
- [ ] Old build caches removed
- [ ] .gitignore properly configured
- [ ] No untracked files should remain

---

### Step 3: Quality Checks (on release branch)

```bash
# Run complete test suite
npm run test:run

# Generate coverage report
npm run test:coverage

# Verify coverage meets standards (target: ≥70%)
# Build and check for errors
npm run build

# Run pre-push validation
npm run pre-push
```

**Checklist**:
- [ ] All tests pass
- [ ] Coverage meets target
- [ ] Build succeeds
- [ ] No linting errors

**If tests fail**: Fix in master, recreate release branch from master

---

### Step 4: Update Documentation (on release branch)

#### 4.1) Update CHANGELOG.md

```markdown
## [<VERSION>] - <YYYY-MM-DD>

### Added
- New feature descriptions

### Changed  
- Improvement descriptions

### Fixed
- Bug fix descriptions

### Removed
- Removed feature descriptions
```

**Checklist**:
- [ ] CHANGELOG follows Keep a Changelog format
- [ ] All changes from master since last release documented
- [ ] Version and date correct

#### 4.2) Update README.md

- Update version references (if any)
- Update feature descriptions (if changed)  
- Update install/setup instructions (if changed)

**Checklist**:
- [ ] Version references updated
- [ ] Getting started section current
- [ ] Links and references valid

#### 4.3) Update other docs (if applicable)

- Architecture docs (if design changed)
- API docs (if interface changed)
- Configuration docs (if options changed)

---

### Step 5: Verify Updated Content (on release branch)

Review all changes on release branch:

```bash
# Show commits on release branch vs master
git log --oneline master..release/v<VERSION>

# Review file changes
git diff master...release/v<VERSION> -- docs/

# Verify no unintended changes
git status
```

**Checklist**:
- [ ] Only intended changes appear
- [ ] No accidental modifications
- [ ] All documentation updates complete

---

### Step 6: Create Release Commit (on release branch)

Use `_git-commit` skill to create a well-formatted release commit:

```bash
# Stage all changes
git add -A

# Use _git-commit skill to format message
# Typical message:
# chore(release): v<VERSION> release preparation
#
# - Update CHANGELOG.md for v<VERSION>
# - Update documentation and guides
# - Clean build caches and artifacts
```

---

### Step 7: Create Pull Request (via _pr-creator skill)

Use `_pr-creator` skill to create professional PR:

**PR Title**: `release: v<VERSION> release preparation`

**PR Description includes**:
- Summary of changes from CHANGELOG
- Release checklist (test pass, docs updated, etc)
- Instructions for manual merge by user
- Note that CI must pass before merging

**Important**: Do NOT auto-merge - user reviews and merges manually

```bash
# Push release branch
git push origin release/v<VERSION>

# Create PR (use _pr-creator skill)
# Wait for CI to pass
# User reviews and merges
```

**Checklist**:
- [ ] PR created with clear title and description
- [ ] All CI checks pass
- [ ] User reviews changes
- [ ] PR merged to master (prefer "Squash and merge")

---

### Step 8: Create GitHub Release (on master after PR merge)

After PR is merged to master:

```bash
# Update to latest master
git checkout master
git pull origin master

# Update version (creates commit and tag)
npm run version:patch  # or minor/major

# This automatically:
# - Updates package.json version
# - Creates version commit
# - Creates git tag

# Push commits and tags
git push origin master --tags
```

**Checklist**:
- [ ] Version updated in package.json
- [ ] Version commit created
- [ ] Git tag created (vX.Y.Z)
- [ ] Commits and tags pushed to remote

Alternatively, create release manually:
```bash
gh release create v<VERSION> --generate-notes
```

---

### Step 9: Post-release Cleanup (on master)

```bash
# Delete local release branch
git branch -d release/v<VERSION>

# Delete remote release branch (if pushed)
git push origin --delete release/v<VERSION>

# Verify remote state
git branch -a | grep release  # Should be empty
```

**Checklist**:
- [ ] Local release branch deleted
- [ ] Remote release branch deleted
- [ ] master and remote synchronized
- [ ] Version tag exists (git tag | grep <VERSION>)

---

## Key Principles

1. **Branch Isolation**: All release work happens on `release/v<VERSION>` branch
   - Protects master from incomplete changes
   - Allows reverting entire release if needed
   - Clear separation of concerns

2. **Quality Gates**: Tests and builds must pass before PR creation
   - Ensures release doesn't introduce regressions
   - Documentation verified before release
   - No surprises after merge

3. **Manual User Control**: User manually merges PR and approves final release
   - Respects human review step
   - Allows last-minute adjustments
   - Clear accountability for releases

4. **Clean History**: Use commit skills for professional messages
   - Release commits are documented
   - Changelog is canonical source of change history
   - CI/CD integration requires proper formatting

---

## Troubleshooting

### Tests fail
- Fix issues in master
- Delete release branch
- Recreate from master
- Reattempt

### Forgot to update documentation
- Add commits to release branch
- Update PR with additional commits
- Or add supplementary commit after merge

### GitHub Release not auto-created
```bash
# Create manually
gh release create v<VERSION> --generate-notes
# Or in GitHub Web UI
```

### Need to cancel release
```bash
# Delete release branch
git branch -d release/v<VERSION>
git push origin --delete release/v<VERSION>

# Delete the tag (if created)
git tag -d v<VERSION>
git push origin --delete v<VERSION>
```

---

## Related Skills

- **_git-commit**: Format release commit messages
- **_pr-creator**: Create release PR with proper description
- **_code-health-check**: Verify code quality before release
