---
name: evolution-core
description: Evolution capability meta-skill. Identifies evolutionary scenarios (repeated errors, user feedback, complex workflows) and crystallizes experience into reusable skills or instruction updates.
---

# _evolution-core

## 📌 Skill Description
- **Purpose**: Transform "experience summary and improvement" into an executable process.
- **Applicable Scenarios**: Repeated errors, user feedback indicating deviations, repetitive time-consuming or high-risk tasks.
- **Learning Source**: Evolution constitution practice.

### ⚡ Important Notice (v2.0.0+)
**All skills are located in `.agent/skills/` directory.** The evolution process must respect this constraint:
- When modifying or creating skills, always target `.agent/skills/<skill_name>/SKILL.md`
- The evoskills CLI fetches skills from `.agent/skills/` via GitHub raw content URLs
- This applies to the source repository (copilot-evolution-skills) and all user projects

## 🔍 Trigger Conditions (Any one triggers)
1. **Repeated Errors**: Same type of error appears in the same session or across multiple sessions.
2. **User Feedback**: User explicitly indicates behavior doesn't meet expectations.
3. **Complex Workflows**: Same type of task is repeatedly time-consuming/high-risk/error-prone.
4. **Skill Failure**: A skill was used, but the process still failed or deviated (e.g., script/tool error, missed key steps).

## ✅ Execution Flow (6 Steps)
1. **Identify**: Describe the problem and trigger type in one sentence.
2. **Attribute**: Find the root cause (missing process/type misunderstanding/improper tool usage).
3. **Abstract**: Extract into reusable rules or processes.
4. **Implement**:
   - If it's a universal rule → Update `.github/copilot-instructions.md` (constitution/guide level).
       - If it's a reusable process → Create or improve skill file under `.agent/skills/<skill>/SKILL.md`.
5. **Register**:
   - Record in skill registry
   - Add skill definition to the `<project_skills>` section in `AGENTS.md` (see below)
6. **Verify**: Apply the improvement in subsequent work and confirm the problem no longer recurs.

⚠️ **Path Constraint (v2.0.0+)**: All skill modifications target `.agent/skills/<skill>/SKILL.md`. Skills are fetched from `.agent/skills/` by the evoskills CLI via GitHub raw content URLs.

## 🤖 Auto-Evolution Requirements

When **Skill Failure** is triggered, the following remedial actions must be executed (cannot be skipped):

1. **Locate Failure Point**: Identify whether it's "missing skill steps" or "execution path inconsistent with skill".
2. **Immediately Correct Skill**: Supplement missing steps or correct rules in the corresponding `SKILL.md`.
3. **Add Paradigm**: Include "failure example → correct example" comparison in the skill.
4. **Annotate Precautions**: Write key prerequisites that led to failure into the skill's "Common Issues/Checklist".
5. **Self-Check Record**: Explicitly state in this response "Auto-evolution triggered and correction completed".

## 🧭 Output Decision
- **Create New Skill**: When the rule needs independent crystallization and long-term reusability.
- **Improve Existing Skill**: When the problem is a gap or variant of an existing skill.
- **Update Instructions**: When the rule should become a "constitution-level/guide-level" behavioral norm.

## 🧰 Quick Checklist
- [ ] Is the trigger condition clear? (Repeated errors/user feedback/complex workflow)
- [ ] Is the root cause reusable?
- [ ] Is a new skill needed? If not, should instructions be updated?
- [ ] Has it been registered in the skill table?
- [ ] Has post-verification been completed?

## 💡 Naming Conventions (Recommended)
- **Skill directories** should uniformly use the `_` prefix, e.g., `.agent/skills/_evolution-core/`.
- The `_` directory prefix distinguishes evoskills from other skill sources and prevents directory name collisions.
- The `name:` field in `SKILL.md` should **not** include `_`, e.g., `name: evolution-core`.
  - This avoids VS Code validation errors (only lowercase letters, numbers, and hyphens are allowed in `name:`).
  - Directory name and `name:` field intentionally differ — directory controls filesystem isolation, `name:` controls VS Code registration.
- If categorization by domain is needed, subdirectory grouping or unified prefix strategies like `evo-`, `proj-` can be used in the `name:` field.

## 📝 Examples

**Scenario**: TypeScript mock repeatedly reports errors.
- Trigger: Repeated errors
- Handling: Create `_typescript-type-safety` skill
- Registration: Add to custom skill table + AGENTS.md
- Verification: Subsequent mock errors significantly reduced

**Scenario 2**: Frequent long commit messages in command line causing issues.
- Trigger: Repeated errors + user feedback
- Handling: Create `_git-commit` skill
- Registration: Add to skill table and AGENTS.md (custom skills section)
- Verification: Subsequent commits follow specifications, no command line issues

---

## 🔍 Evolution Opportunity Identification Guide

### Identification Pattern A: Repeated Errors

When encountering the same or similar error in the same session or consecutive sessions:

```
Session 1: Error A appears → Fix
Session 2: Error A appears again (or variant) → 🚩 Skill creation opportunity

Action:
1. Analyze why it recurs
2. Extract universal preventive measures
3. Create skill file
4. Update quick checklist in instructions
```

### Identification Pattern B: User Feedback

When user indicates a behavior doesn't meet expectations:

```
User Feedback: "You should check type definitions first, not write mock directly"
       ↓
Understanding: Discovered flaw in my workflow
       ↓
Improvement: Encode user's suggestion as skill and instructions
       ↓
Verification: Apply improvement in subsequent work
```

**Action Checklist**:
- [ ] Understand user's specific guidance
- [ ] Analyze why my approach wasn't good enough
- [ ] Consider if this problem has universality
- [ ] If universal, create or improve skill
- [ ] Update instructions
- [ ] Verify improvement effectiveness when encountered next time

### Identification Pattern C: Complex Workflows

When discovering a certain type of task is always time-consuming or error-prone:

```
Observation: Every time handling certain tasks, stepping on pitfalls
      ↓
Analysis: Do these pitfalls have common root causes?
      ↓
If yes: Create related skill
If no: Record as common pitfalls
```

### 🚀 Skill Creation Decision Tree

```
Encounter Problem
  │
  ├─ Will this problem recur?
  │  ├─ No → Record as common pitfall
  │  └─ Yes → Continue
  │
  ├─ Does the solution have a universal pattern?
  │  ├─ No → Record as project-specific detail
  │  └─ Yes → Continue
  │
  ├─ Is this pattern complex enough to require detailed explanation?
  │  ├─ No → Add to instructions quick checklist
  │  └─ Yes → Continue
  │
  └─ Create new skill!
     ├─ Choose a clear name
     ├─ Write complete SKILL.md
     ├─ Add to instruction file's skill table
     └─ Verify in related work
```

---

## 🔧 Skill Maintenance Guide

### How to Register New Skills in AGENTS.md

After creating a new custom skill, it needs to be manually added to `AGENTS.md`:

**Location**: `<project_skills>` section in `AGENTS.md` (between markers if they exist)

**Format**:
```xml
<skill>
<name>_your-skill-name</name>
<description>Brief description of the skill, explaining purpose, applicable scenarios, core capabilities</description>
<location>project</location>
<path>.agent/skills/_your-skill-name/SKILL.md</path>
</skill>
```

**Key Points**:
- `<name>` uses `_` prefix (distinguishes custom skills)
- `<description>` concise and clear, highlighting core value
- `<location>` fixed as `project`
- `<path>` provides complete relative path

---

## 🔄 Improvement Suggestions

- Currently skill path is fixed to `.agent/skills/`, future could consider categorization by domain
- When skill count increases, can group by category in AGENTS.md
- Consider adding skill dependency declarations (e.g., one skill depends on another)
- Can create "Skill Evolution History" document to record version evolution of each skill

