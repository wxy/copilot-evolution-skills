# copilot-evolution-skills

> 通用 AI 助手技能库 + 工程规范框架 | Universal Skills Library & Engineering Framework for AI Assistants

一套为 Claude/Copilot 等 AI 助手设计的可复用、可演进的**技能库**和**工程规范**。支持跨项目共享、多项目协作、与自动化冲突解决。

---

## 🎯 核心价值

- ✨ **可复用的技能集合** - 13+ 精心设计的工程技能（Git、测试、代码健康等）
- 📚 **通用进化框架** - AI 系统的根本进化法则（独立于具体项目）
- 🔄 **跨项目共享** - 通过 Git Submodule 在多个项目中复用
- 🛠️ **AI 友好** - 完整的集成指南和自动化工具
- 🎓 **即插即用** - 一行指令开始，交互式安装流程

---

## 📦 项目结构

```
copilot-evolution-skills/
├── .github/
│   ├── ai-evolution-constitution.md      # 核心进化框架
│   ├── INSTALLATION.md                    # AI 参考指南
│   ├── CONFLICT_RESOLUTION.md            # 冲突处理策略
│   └── EVOLUTION.md                      # 技能演进机制
├── constitution/
│   └── ai-evolution-constitution.md      # 独立维护的通用框架
├── skills/                               # 13 个自定义技能
│   ├── _evolution-core/
│   ├── _typescript-type-safety/
│   ├── _git-commit/
│   ├── _pr-creator/
│   ├── _code-health-check/
│   ├── _release-process/
│   ├── _context-ack/
│   ├── _instruction-guard/
│   ├── _file-output-guard/
│   ├── _change-summary/
│   ├── _traceability-check/
│   └── _session-safety/
├── templates/                            # 新项目/技能的模板
│   ├── SKILL_TEMPLATE.md
│   ├── INSTRUCTION_TEMPLATE.md
│   └── copilot-instructions-base.md
├── scripts/                              # 交互式脚本
│   ├── setup-interactive.sh              # 一行指令入口
│   ├── validate-installation.sh
│   └── resolve-conflicts.sh
├── docs/                                 # 深度指南
│   ├── AI_INTEGRATION_GUIDE.md           # AI 如何使用本库
│   ├── SKILL_CREATION_GUIDE.md           # 创建新技能
│   ├── MULTI_PROJECT_GUIDE.md            # 多项目共享
│   └── VERSIONING.md                     # 版本管理
├── README.md                             # 本文件
├── SETUP.md                              # 快速开始
├── CHANGELOG.md                          # 变更日志
├── LICENSE                               # MIT License
└── version.txt                           # 版本号
```

---

## 🚀 快速开始

### 方式 1：一行指令（推荐给 AI）

```bash
bash <(curl -s https://raw.githubusercontent.com/YOUR_ORG/copilot-evolution-skills/main/scripts/setup-interactive.sh)
```

### 方式 2：本地克隆后交互式安装

```bash
git clone https://github.com/YOUR_ORG/copilot-evolution-skills.git
cd copilot-evolution-skills
bash scripts/setup-interactive.sh
```

### 方式 3：作为 Submodule 集成

```bash
cd your-project
git submodule add https://github.com/YOUR_ORG/copilot-evolution-skills.git .copilot/skills
bash .copilot/skills/scripts/validate-installation.sh
```

---

## 📋 核心技能清单

| 技能名 | 用途 | 触发场景 |
|-------|------|--------|
| `_evolution-core` | 进化能力元技能 | 识别新的错误模式、优化工作流程 |
| `_typescript-type-safety` | TypeScript Mock 创建与错误预防 | 编译错误、类型不匹配 |
| `_git-commit` | Git 提交规范化 | 提交代码时 |
| `_pr-creator` | PR 创建流程 | 创建 GitHub PR 时 |
| `_code-health-check` | 提交前代码检查 | 提交前验证代码质量 |
| `_release-process` | 完整发布流程 | 版本发布时 |
| `_context-ack` | 上下文校验 | 每次回复时 |
| `_instruction-guard` | 指令读取强制 | 每次回复前 |
| `_file-output-guard` | 文件创建安全 | 创建文件时 |
| `_change-summary` | 提交摘要汇总 | PR 创建时 |
| `_traceability-check` | 说明与变更校验 | PR 创建前 |
| `_session-safety` | 会话超长防护 | 输出过长时 |

---

## 📖 核心文档

- **[SETUP.md](./SETUP.md)** - 详细的安装和配置指南
- **[.github/INSTALLATION.md](./.github/INSTALLATION.md)** - AI 参考指南
- **[.github/CONFLICT_RESOLUTION.md](./.github/CONFLICT_RESOLUTION.md)** - 多项目冲突处理
- **[docs/AI_INTEGRATION_GUIDE.md](./docs/AI_INTEGRATION_GUIDE.md)** - AI 如何使用本库
- **[docs/SKILL_CREATION_GUIDE.md](./docs/SKILL_CREATION_GUIDE.md)** - 创建新技能流程
- **[CHANGELOG.md](./CHANGELOG.md)** - 版本历史

---

## 🔄 使用场景

### 场景 1：新项目集成
```bash
# 新项目中使用技能库
git submodule add https://... .copilot/skills
cp .copilot/skills/templates/copilot-instructions-base.md .github/copilot-instructions.md
# 编辑 copilot-instructions.md，填充 Part 2（项目特定）
```

### 场景 2：多项目共享
```bash
# 项目 A 和项目 B 都通过 submodule 引用同一版本
# 自动继承最新的技能改进
git submodule update --remote
```

### 场景 3：项目定制
```bash
# 若某项目需要定制技能
mkdir .copilot/skills-overrides
cp .copilot/skills/_skill-name/SKILL.md .copilot/skills-overrides/
# 编辑定制版本，项目指令中加载 override
```

---

## 🛠️ 开发与贡献

### 创建新技能
1. 参考 [docs/SKILL_CREATION_GUIDE.md](./docs/SKILL_CREATION_GUIDE.md)
2. 在 `skills/` 目录下创建 `_skill-name/` 文件夹
3. 编写 SKILL.md（参考 `templates/SKILL_TEMPLATE.md`）
4. 创建 PR，描述技能触发条件和应用场景

### 改进现有技能
- 遵循 [.github/EVOLUTION.md](./.github/EVOLUTION.md) 的演进机制
- 更新版本号和 CHANGELOG
- 创建 PR 并获得审批

### 冲突处理
- 参考 [.github/CONFLICT_RESOLUTION.md](./.github/CONFLICT_RESOLUTION.md) 的三种策略
- 推荐使用 Three-way Merge 方案

---

## 📊 版本管理

采用 Semantic Versioning：
- **MAJOR**: 架构变化（文件结构、用法改变）
- **MINOR**: 新技能、主要改进
- **PATCH**: 文档更新、小修复

当前版本：`1.0.0-beta`（设计完成，等待初始化）

---

## 🎓 AI 友好设计

本项目完全为 AI 助手（如 Claude、Copilot）设计：

- ✅ 每个技能都有清晰的**触发条件**和**执行步骤**
- ✅ 包含 **AI 集成指南**（如何读取、使用、改进技能）
- ✅ 提供**自动化脚本**（一行指令安装，交互式配置）
- ✅ 详细的**冲突处理决策树**
- ✅ **技能创建标准化**（模板 + 清单）

AI 可以：
1. 独立读取本库的任何文档
2. 按照技能中的步骤执行任务
3. 遇到问题时查阅相应技能或指南
4. 识别新的错误模式并创建新技能

---

## 📝 许可证

MIT License - 详见 [LICENSE](./LICENSE) 文件

---

## 🤝 致谢

本项目源于 [SilentFeed](https://github.com/YOUR_ORG/SilentFeed) 的自定义技能实践，现已独立为可复用库。

---

## 📮 反馈与讨论

- 遇到问题？参考 [docs/](./docs/) 目录中的深度指南
- 想贡献新技能？参考 [docs/SKILL_CREATION_GUIDE.md](./docs/SKILL_CREATION_GUIDE.md)
- 有建议？创建 Issue 或 Discussion
