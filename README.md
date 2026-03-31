# evoskills

> Evolution Skills CLI - A modular, evolvable AI skills framework for GitHub Copilot

[![npm version](https://img.shields.io/npm/v/@xingyu.wang/evoskills.svg)](https://www.npmjs.com/package/@xingyu.wang/evoskills)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**evoskills** is a CLI tool and skill framework that enhances AI assistants (like GitHub Copilot) with modular, reusable capabilities. It provides a self-improving system through constitutional AI guidelines and pluggable skills.

## ✨ Features

- 🧩 **Modular Skills**: Install only the skills you need
- 🔄 **Self-Improving**: Built-in evolution mechanism learns from mistakes
- 🛡️ **Safe by Default**: Content protection prevents overwriting user customizations  
- 📦 **openskills Compatible**: Works with standard openskills format
- 🌐 **Extensible**: Create your own skill repositories
- 🚀 **Zero Config**: Sensible defaults, auto-saves configuration

## 📦 Installation

### Option 1: Global Install (Recommended for regular use)

```bash
npm install -g @xingyu.wang/evoskills
```

Then use anywhere:

```bash
evoskills --help
```

### Option 2: Use with npx (No installation required)

```bash
npx @xingyu.wang/evoskills init
```

### Option 3: AI Integration (One-sentence setup)

Tell your AI assistant (e.g., GitHub Copilot) directly:

> Please integrate the skills from https://github.com/wxy/evoskills into this project.

The AI will read this README, understand the skill system, and execute the setup via the CLI:

```bash
npx @xingyu.wang/evoskills init
```

This works with any AI assistant that can browse GitHub URLs. The CLI handles all file placement, registry generation, and content protection — direct file copying is not supported and will result in an incomplete setup.

## 🚀 Quick Start

Initialize evoskills in your project:

```bash
cd /path/to/your/project
evoskills init
```

This will:
- ✅ Create `.agent/skills/` directory (skills installed from GitHub)
- ✅ Generate `AGENTS.md` at project root (openskills-compatible skill registry)
- ✅ Download `.github/AI_CONSTITUTION.md` (core evolution mechanism)
- ✅ Download `.github/AI_INITIALIZATION.md` (mandatory 4-skill initialization protocol)
- ✅ Create `.github/copilot-instructions.md` (entry point for the system)
- ✅ Save configuration to `.evoskills-config.json`

**Architecture:**
1. **AI Constitution** - Core evolution principles (always active)
2. **Initialization Protocol** - Mandatory 4-skill execution sequence with verifiable markers
3. **Skills** - Reusable capabilities with 3 tiers:
  - Core (2): evolution infrastructure
  - Required System (4): safety/runtime baseline (enforced by initialization protocol)
  - Optional (8): user-selectable workflow enhancements
4. **Framework Files Management** - Dynamic and user-maintained files with protection:
  - Framework files (`.github/AI_CONSTITUTION.md`, `.github/AI_INITIALIZATION.md`) are auto-generated for external projects
  - `AGENTS.md` is protected: auto-generated in external projects, user-maintained in evoskills repository
  - The CLI detects when running on itself and skips auto-updates to prevent overwriting user customizations

## 📚 Usage

### List Available Skills

```bash
evoskills list                   # Show all available skills
evoskills list --installed       # Show installed skills only
```

### Initialize by Tier

```bash
evoskills init                   # Install core + required + optional (default)
evoskills init --core-only       # Install only core skills (2)
evoskills init --required-only   # Install core + required system skills (6)
evoskills init --skills _git-commit,_pr-creator  # Install selected optional skills
```

### Install/Remove Skills

```bash
evoskills install _git-commit    # Install a skill
evoskills remove _git-commit     # Remove a skill
```

### Update Skills

```bash
evoskills update                 # Refresh all installed skills and framework files
evoskills update _git-commit     # Update specific skill only
```

`evoskills update` will check for a newer CLI version and print a prompt, but it will not auto-install.
To update CLI explicitly:

```bash
npm install -g @xingyu.wang/evoskills@latest
```

### npm Release Authentication (GitHub Actions)

- Preferred: **Trusted Publishing (OIDC)**, no token needed
- Fallback: **Granular access token** stored as `NPM_TOKEN` in GitHub Secrets
- Note: npm legacy tokens were removed (Nov 2025), so "Automation token" may not appear in UI

### Use Custom Skill Repository

```bash
evoskills init --repo https://github.com/your-username/your-skills-repo
evoskills update --repo <url>    # Switch repository and update all skills
```

The repository URL is auto-saved to `.evoskills-config.json`.

## 🎯 Available Skills

The default repository provides 14 skills in a 3-tier model:

### Tier 1: Core Skills (2)
- `_evolution-core` - Identifies improvement opportunities and proposes enhancements
- `_skills-manager` - Manages skill lifecycle (install/remove/update/contribute)

### Tier 2: Required System Skills (4)
- `_instruction-guard` - Ensures project instructions are applied before responses
- `_context-ack` - Formats responses with clear context and references
- `_file-output-guard` - Safeguards file operations and output behavior
- `_execution-precheck` - Validates dependencies before execution

### Tier 3: Optional Skills (8)
- `_git-commit` - Conventional commits workflow
- `_pr-creator` - PR generation workflow
- `_release-process` - End-to-end release process
- `_code-health-check` - Pre-commit quality checks
- `_typescript-type-safety` - Type safety and mock patterns
- `_change-summary` - Session change summarization
- `_traceability-check` - Decision traceability checks
- `_session-safety` - Session state consistency safeguards

## 🛡️ User Content Protection

evoskills intelligently preserves your customizations during updates:

### AGENTS.md Protection
- Managed region marked with `<!-- EVOSKILLS_START -->` and `<!-- EVOSKILLS_END -->`
- Content outside markers is preserved (your custom skills, notes, etc.)
- Updates only replace content between markers
- If no markers exist, content is appended (never overwritten)

### copilot-instructions.md Protection
- New file: Creates standard template with required references
- Existing file: Checks for `AI_CONSTITUTION.md`, `AI_INITIALIZATION.md`, and `AGENTS.md` references
- Only appends missing references, never overwrites existing content

**Example**: You can safely add your own skill groups to `AGENTS.md` - evoskills updates won't touch them.

## 📂 Project Structure

This repository uses the same `.agent/skills/` structure it creates for users (dogfooding):

```
.agent/skills/          # Skill source definitions (14 skills)
evoskills               # CLI entry point (npm bin)
.github/
  AI_CONSTITUTION.md    # Constitutional template
AGENTS.md               # Skill registry (openskills format)
package.json            # npm package metadata
```

When users install skills from GitHub, evoskills downloads from the `.agent/skills/` path.

## 🤝 Contributing

Contributions are welcome! See our [contribution guidelines](SKILL_DEFINITION_SPECIFICATION.md) for details.

Quick contribution workflow:

```bash
git checkout -b feat/your-feature
# Make your changes in .agent/skills/
git commit -m "feat: add new skill"
git push -u origin feat/your-feature
# Create PR (with GitHub CLI)
gh pr create --fill
```

## 📄 License

MIT © [wxy](https://github.com/wxy)

## 🔗 Links

- [npm Package](https://www.npmjs.com/package/@xingyu.wang/evoskills)
- [GitHub Repository](https://github.com/wxy/evoskills)
- [Skill Definition Specification](SKILL_DEFINITION_SPECIFICATION.md)
