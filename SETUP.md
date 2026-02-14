# 快速开始 - copilot-evolution-skills

## 一行指令（用于 AI）

```bash
bash <(curl -s https://raw.githubusercontent.com/YOUR_ORG/copilot-evolution-skills/main/scripts/setup-interactive.sh)
```

## 交互式安装

或直接运行本地安装脚本：

```bash
bash scripts/setup-interactive.sh
```

---

## 安装流程说明

### 步骤 1：选择安装目录

系统会提示你选择安装位置：

```
请选择安装目录 (默认: .copilot/):
[1] .copilot/         (默认)
[2] .claude/          (Claude 项目)
[3] .github/          (GitHub Action)
[4] 自定义路径
```

**推荐**：使用 `.copilot/` 作为标准位置。

### 步骤 2：选择安装组件

```
请选择要安装的组件:
[1] 完整安装        (所有技能 + 模板 + 文档)
[2] 最小安装        (核心技能 + 基础文档)
[3] 自定义选择      (按需勾选)
```

**完整安装** 包括：
- 13 个自定义技能
- 项目模板和指令模板
- 所有文档和指南

**最小安装** 包括：
- 核心技能（git-commit、code-health-check、context-ack）
- TypeScript 类型安全技能
- 基础文档

### 步骤 3：生成项目指令

系统会自动为你的项目生成 `copilot-instructions.md`，包括：
- Part 1：通用进化宪法的 attachment 引用
- Part 2：（需要你编辑）项目特定规范
- Part 3：技能库说明

### 步骤 4：验证安装

脚本会检查：
- ✅ 所有技能文件存在
- ✅ copilot-instructions.md 已生成
- ✅ attachment 链接正确
- ✅ Markdown 语法正确

### 步骤 5：初始化 Git（可选）

如果这是新项目，脚本会问你是否初始化 Git：

```bash
git init
git add .
git commit -m "chore: 初始化项目，集成 copilot-evolution-skills"
```

---

## 使用示例

### 示例 1：新项目完整集成

```bash
# 创建新项目目录
mkdir my-ai-project
cd my-ai-project

# 运行安装脚本
bash <(curl -s https://raw.githubusercontent.com/YOUR_ORG/copilot-evolution-skills/main/scripts/setup-interactive.sh)

# 选择：完整安装 → .copilot/ → 生成指令 → 初始化 Git
```

完成后，你的项目结构为：
```
my-ai-project/
├── .copilot/
│   ├── skills/              (Submodule 或本地复制)
│   └── skills-overrides/    (项目定制)
├── .github/
│   ├── copilot-instructions.md
│   └── COMMIT_DESCRIPTION.local.md
└── ...
```

### 示例 2：添加到现有项目

```bash
cd existing-project
bash <(curl -s https://raw.githubusercontent.com/YOUR_ORG/copilot-evolution-skills/main/scripts/setup-interactive.sh)

# 选择：最小安装 → .copilot/ → 检查现有指令
```

### 示例 3：使用 Git Submodule（推荐用于长期维护）

```bash
cd my-project
git submodule add https://github.com/YOUR_ORG/copilot-evolution-skills.git .copilot/skills
bash .copilot/skills/scripts/validate-installation.sh

# 更新时
git submodule update --remote
```

---

## 验证安装

安装完成后，运行验证脚本：

```bash
bash .copilot/skills/scripts/validate-installation.sh
```

输出应为：
```
✅ 所有技能文件验证通过
✅ copilot-instructions.md 格式正确
✅ Markdown 语法验证通过
✅ Attachment 链接有效
┌────────────────────────────────────┐
│ 安装验证完成！                      │
│ 你现在可以使用所有技能               │
└────────────────────────────────────┘
```

---

## 常见问题

### Q: 我已经有 copilot-instructions.md，怎么办？

A: 脚本会备份你的原文件为 `copilot-instructions.md.bak`，然后生成新文件。你可以：
1. 比较两个文件，手动合并
2. 恢复备份：`mv copilot-instructions.md.bak copilot-instructions.md`

### Q: 我想使用 Git Submodule，但项目还不是 Git 仓库

A: 先初始化 Git：
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-repo-url>
```

然后再添加 submodule。

### Q: 某项技能不适合我的项目，怎么办？

A: 有三种选择：

**选项 1：禁用该技能**
- 在项目的 copilot-instructions.md 中移除该技能的说明

**选项 2：定制该技能**
- 创建 `.copilot/skills-overrides/<skill-name>/SKILL.md`
- 在项目指令中加载 override 版本

**选项 3：删除该技能**
- 删除 `.copilot/skills/<skill-name>/` 目录（不推荐，下次更新会重新出现）

### Q: 如何更新到最新版本？

A: 如果使用 Submodule：
```bash
git submodule update --remote
```

如果是本地复制：
```bash
# 重新运行安装脚本
bash <(curl -s https://raw.githubusercontent.com/YOUR_ORG/copilot-evolution-skills/main/scripts/setup-interactive.sh)
```

### Q: 与其他项目的冲突怎么处理？

A: 参考 [.github/CONFLICT_RESOLUTION.md](./.github/CONFLICT_RESOLUTION.md)

---

## 下一步

1. **阅读项目指令** - `cat .github/copilot-instructions.md`
2. **浏览可用技能** - `ls .copilot/skills/*/`
3. **深入学习** - 参考 [docs/](./docs/) 目录
4. **开始使用** - 按照各个技能的说明执行任务

---

## 获取帮助

- 📖 [docs/AI_INTEGRATION_GUIDE.md](./docs/AI_INTEGRATION_GUIDE.md) - AI 如何使用本库
- 🛠️ [docs/SKILL_CREATION_GUIDE.md](./docs/SKILL_CREATION_GUIDE.md) - 创建新技能
- 🔄 [.github/CONFLICT_RESOLUTION.md](./.github/CONFLICT_RESOLUTION.md) - 冲突处理
- 📝 [.github/EVOLUTION.md](./.github/EVOLUTION.md) - 技能演进机制

祝你使用愉快！🚀
