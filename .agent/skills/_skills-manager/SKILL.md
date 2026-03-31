---
name: skills-manager
description: Core skill manager for evoskills. Handles skill lifecycle (init, install, remove, update) and skill contributions.
---

# _skills-manager

## 📌 Skill Description

Manages the complete skill lifecycle in copilot-evolution-skills projects. Works with the evoskills CLI to install, update, and maintain AI skills.

**Applicable Scenarios**: Initializing projects with skills, installing/removing specific skills, updating skill definitions, contributing skill improvements.

**Learning Source**: evoskills CLI workflow and openskills compatibility patterns.

## 🎯 Core Operations

### Initialize Project
```bash
evoskills init                    # Install all core skills
evoskills init --core-only        # Core skills only
evoskills init --skills a,b,c     # Specific skills
```

Creates `.agent/skills/`, `AGENTS.md`, `.github/AI_CONSTITUTION.md`.

### Install/Remove Skills
```bash
evoskills install _git-commit     # Install optional skill
evoskills remove _git-commit      # Remove (core skills locked)
evoskills list --installed        # Show installed skills
```

### Update Skills
```bash
evoskills update                  # Sync all skills
evoskills update _git-commit      # Update specific skill
```

## ⚡ Critical Path Constraint (v2.0.0+)

- ✅ All skill sources in `.agent/skills/<skill_name>/SKILL.md`
- ❌ Never use deprecated `skills/` directory
- ✅ evoskills CLI fetches from `.agent/skills/` via GitHub raw content

## 🔄 Contributing Improvements

When improving a skill:

```bash
git checkout -b feat/improve-skill-name
# Edit .agent/skills/<skill_name>/SKILL.md
git add .agent/skills/<skill_name>/
git commit -m "feat(_skill-name): describe improvement"
git push -u origin feat/improve-skill-name
```

## 🚀 evoskills CLI Reference

| Command | Purpose |
|---------|---------|
| `evoskills init` | Initialize project with skills |
| `evoskills list` | Show all available skills |
| `evoskills install <skill>` | Install optional skill |
| `evoskills remove <skill>` | Remove optional skill |
| `evoskills update` | Sync all skills to latest |

## 🧙 Integration with _evolution-core

When `_evolution-core` identifies skill improvements:
1. Locate skill at `.agent/skills/<skill_name>/SKILL.md`
2. Apply improvements directly to that file
3. Never create duplicates in other directories
4. Register changes in `AGENTS.md` if adding new skills

## ✅ Pre-Contribution Checklist

- [ ] Skill location is `.agent/skills/<skill_name>/SKILL.md`
- [ ] SKILL.md content is concise (60-150 lines)
- [ ] No deprecated `skills/` paths used
- [ ] AGENTS.md updated if new skills added
- [ ] PR description includes "What changed" and "Why"
