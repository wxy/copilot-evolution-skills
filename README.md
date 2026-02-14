# copilot-evolution-skills

> 通用 AI 助手技能库 + 工程规范框架

一套为 Claude/Copilot 等 AI 助手设计的可复用、可演进的**技能库**和**工程规范**。支持跨项目共享、多项目协作、与自动化冲突解决。

---

## 🎯 核心价值

- ✨ **可复用的技能集合** - 12+ 精心设计的工程技能（Git、测试、代码健康等）
- 📚 **通用进化框架** - AI 系统的根本进化法则（独立于具体项目）
- 🔄 **跨项目共享** - 通过 Git Submodule + Sparse Checkout 在多个项目中复用
- 🛠️ **AI 友好** - 完整的集成指南，AI 可自动完成
- 🎓 **用户无感** - 一句话集成，AI 全自动完成复杂工作

---

## 🚀 快速开始

### 用户只需说一句话

```
请集成 https://github.com/wxy/copilot-evolution-skills 下的技能到本项目
```

就这样！AI 会自动完成所有工作。

---

## 📖 AI 集成指南

当用户请求集成本库时，AI 应该按照以下步骤操作：

### 第一步：了解本项目

- 你正在读的就是官方说明
- 本项目包含 12 个通用技能库 + 1 个进化宪法框架
- 集成方式：Git Submodule + Sparse Checkout（节省空间、保持同步）

### 第二步：一条命令完成集成

在用户项目的根目录执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/setup-submodule.sh)
```

脚本会自动完成：
1. ✅ 添加 submodule 到 `.copilot/skills/`
2. ✅ 配置稀疏检出（仅下载 `skills/` 和 `constitution/`）
3. ✅ 创建/更新 `.github/copilot-instructions.md`
4. ✅ 自动提交变更

### 第三步：验证集成

```bash
git submodule status
# 应该看到：+<commit-hash> .copilot/skills (...)

ls -la .copilot/skills/
# 应该看到 skills/ 和 constitution/ 目录
```

### 第四步：推送完成

```bash
git push
```

用户就完成了！现在 12 个技能已经可用。

---

## 📦 项目结构

```
copilot-evolution-skills/
├── skills/                          # 12 个自定义技能
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
├── constitution/
│   └── ai-evolution-constitution.md  # 通用进化宪法框架
├── scripts/
│   ├── setup-submodule.sh            # 一键集成脚本（推荐）
│   ├── integrate-to-project.sh       # 备用集成脚本
│   └── verify-integration.sh         # 验证脚本
├── README.md                         # 本文件
├── LICENSE                           # MIT License
└── version.txt                       # 版本号
```

---

## 📋 核心技能清单

| 技能名 | 用途 |
|-------|------|
| `_evolution-core` | 进化能力元技能 |
| `_typescript-type-safety` | TypeScript Mock 创建与错误预防 |
| `_git-commit` | Git 提交规范化 |
| `_pr-creator` | PR 创建与版本控制流程 |
| `_code-health-check` | 提交前代码检查 |
| `_release-process` | 完整的发布流程 |
| `_context-ack` | 上下文校验与输出格式 |
| `_instruction-guard` | 强制读取指令文件 |
| `_file-output-guard` | 文件创建安全约束 |
| `_change-summary` | 提交摘要汇总 |
| `_traceability-check` | 说明与变更校验 |
| `_session-safety` | 会话超长防护 |

---

## 🔄 后续维护

### 更新到最新版本

```bash
git submodule update --remote
git commit -am "chore: 更新 copilot-evolution-skills"
git push
```

### 跨多个项目共享

所有集成了本库的项目可以保持同步，自动继承最新的技能改进。

---

## 📝 许可证

MIT License - 详见 [LICENSE](./LICENSE) 文件

---

## 🤝 致谢

源于 [SilentFeed](https://github.com/wxy/SilentFeed) 的自定义技能实践，现已独立为可复用库。
