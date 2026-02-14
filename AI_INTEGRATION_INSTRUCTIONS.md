# AI 集成指令

> 🤖 **本文档供 AI 助手读取和执行**。用户只需一句话告诉 AI："请集成 copilot-evolution-skills 到我的项目"，AI 自动处理所有细节。

---

## 集成的含义

当用户要求集成本技能库时，你（AI）需要：

1. **将核心文件复制到用户项目**
   - `skills/` → 用户项目的 `.evolution-skills/skills/`
   - `constitution/` → 用户项目的 `.evolution-skills/constitution/`

2. **更新或创建用户项目的 `copilot-instructions.md`**
   - 通过 `<attachment>` 标签引用进化宪法
   - 保留或新增 Part 2（项目特定规范）
   - 保留或新增 Part 3（技能库说明）

3. **验证集成完整性**
   - 检查所有技能文件
   - 验证路径和引用

4. **记录集成信息**
   - 创建 `.github/SKILLS_INTEGRATION_INFO.md`
   - 提交更改（如果是 Git 项目）

---

## 执行集成的步骤

### 前置条件
- 你有权访问本技能库的 `scripts/` 目录
- 目标项目路径有效且可写

### 集成流程

#### 步骤 1：运行集成脚本
```bash
bash scripts/integrate-to-project.sh /path/to/user-project
```

**脚本的职责**：
- ✅ 检查目标项目有效性
- ✅ 创建 `.evolution-skills/` 目录结构
- ✅ 复制 `skills/` 和 `constitution/` 目录
- ✅ 生成或更新 `copilot-instructions.md`
- ✅ 添加 attachment 引用
- ✅ 创建 `.github/SKILLS_INTEGRATION_INFO.md`
- ✅ 如果是 Git 项目，自动提交
- ✅ 返回成功状态

#### 步骤 2：验证集成
```bash
bash scripts/verify-integration.sh /path/to/user-project
```

**验证脚本的职责**：
- ✅ 检查所有技能文件完整性
- ✅ 验证 attachment 引用正确
- ✅ 检查 Markdown 语法
- ✅ 生成详细的验证报告

#### 步骤 3：向用户报告
汇总以下信息：
```
✅ 集成完成！

已集成内容：
- 12 个自定义技能
- 通用进化宪法
- 项目指令文件（已配置）

目录结构：
.evolution-skills/
├── skills/              (12 个技能)
├── constitution/        (进化宪法)
└── README.md           (使用说明)

.github/
├── copilot-instructions.md      (已更新，含 attachment 引用)
└── SKILLS_INTEGRATION_INFO.md   (集成信息)

所有验证通过，项目已就绪使用所有技能！
```

---

## 脚本实现细节

### integrate-to-project.sh

**用途**：一键集成技能库到用户项目

**调用方式**：
```bash
bash scripts/integrate-to-project.sh /path/to/user-project [--auto-commit]
```

**参数**：
- `<project-path>` (必需) - 用户项目的根目录
- `--auto-commit` (可选) - 自动提交更改（仅当项目是 Git 仓库时）

**脚本逻辑**：

1. **验证参数**
   - 检查目标项目路径是否存在
   - 检查本脚本自身位置（确定技能库根目录）

2. **创建目录**
   - 创建 `<project>/.evolution-skills/`

3. **复制核心文件**
   - 从技能库复制 `skills/` → `<project>/.evolution-skills/skills/`
   - 从技能库复制 `constitution/` → `<project>/.evolution-skills/constitution/`
   - 保留 `<project>/.evolution-skills/` 中用户的任何定制文件（如 `skills-overrides/`）

4. **处理 copilot-instructions.md**
   - 如果文件不存在，使用模板创建
   - 如果存在，检查是否有 `<attachment filePath=".evolution-skills/constitution/ai-evolution-constitution.md">`
   - 如果缺失，在 Part 1 后添加
   - 保留用户的 Part 2 和 Part 3

5. **创建集成信息文件**
   - 生成 `.github/SKILLS_INTEGRATION_INFO.md`
   - 记录集成日期、版本号、包含的技能列表

6. **Git 提交（可选）**
   - 如果 `--auto-commit` 且目标是 Git 项目
   - 创建提交说明文件（`.github/COMMIT_DESCRIPTION.local.md`）
   - 执行 `git commit -F .github/COMMIT_DESCRIPTION.local.md`
   - 清理说明文件

7. **返回状态**
   - 成功：退出码 0，输出集成信息
   - 失败：退出码 1，输出错误信息

**返回示例**（标准输出）：
```
✅ 集成完成

已复制：
- skills/ (12 个技能)
- constitution/ (进化宪法)

已更新：
- .github/copilot-instructions.md
- .github/SKILLS_INTEGRATION_INFO.md

已验证：
- 所有文件完整
- Markdown 语法正确
- 引用链接有效

项目位置：/path/to/user-project
集成时间：2026-02-14 16:00:00
版本号：1.0.0-beta
```

---

### verify-integration.sh

**用途**：验证集成是否完整且正确

**调用方式**：
```bash
bash scripts/verify-integration.sh /path/to/user-project [--verbose]
```

**验证项目**：
1. ✅ 技能文件完整性（检查 12 个 SKILL.md）
2. ✅ 目录结构（`.evolution-skills/` 存在且包含正确子目录）
3. ✅ 进化宪法存在和可读
4. ✅ copilot-instructions.md 语法和 attachment 引用
5. ✅ SKILLS_INTEGRATION_INFO.md 存在
6. ✅ 没有冲突或重复文件

**返回示例**（成功）：
```
验证报告 - /path/to/user-project

✅ 技能文件验证
   └─ 12 个 SKILL.md 文件完整

✅ 目录结构验证
   └─ .evolution-skills/ 存在
   └─ skills/ 包含 12 个技能目录
   └─ constitution/ 包含进化宪法

✅ copilot-instructions.md 验证
   └─ 文件存在且可读
   └─ Markdown 语法正确
   └─ attachment 引用正确

✅ 集成信息验证
   └─ SKILLS_INTEGRATION_INFO.md 存在

所有验证通过！ ✨
```

---

## 集成后用户项目的结构

集成完成后，用户项目的结构如下：

```
user-project/
├── .copilot/
│   └── skills/                              (技能库集成的位置)
│       ├── skills/                          (12 个技能)
│       │   ├── _git-commit/
│       │   ├── _typescript-type-safety/
│       │   └── ... (其他 10 个)
│       └── constitution/
│           └── ai-evolution-constitution.md
├── .github/
│   ├── copilot-instructions.md              (已更新，含 attachment 引用)
│   └── SKILLS_INTEGRATION_INFO.md           (集成信息和说明)
├── README.md                                (用户项目的 README，不变)
└── ... (用户项目的其他文件)
```

**关键文件说明**：

- **.evolution-skills/skills/** - 12 个自定义技能，用户的 AI 可以直接使用
- **.evolution-skills/constitution/** - 通用进化宪法，所有项目共享
- **.github/copilot-instructions.md** - 项目指令文件，通过 attachment 引用进化宪法
- **.github/SKILLS_INTEGRATION_INFO.md** - 集成信息（何时集成、版本号、更新方法等）

---

## 更新已集成的技能库

如果技能库有新版本，用户可以请求 AI 更新：

```bash
bash .evolution-skills/scripts/update-integration.sh [--backup]
```

**更新脚本**：
- 备份当前版本（可选）
- 复制最新的 skills 和 constitution
- 保留用户的定制文件
- 验证更新
- 提交更改（如果是 Git 项目）

---

## 常见问题

### Q: 如果用户项目已有 `.evolution-skills/` 怎么办？

A: 脚本会：
1. 备份现有内容为 `.copilot/skills.backup.<timestamp>/`
2. 复制新文件
3. 提醒用户检查备份

### Q: 如果 copilot-instructions.md 有用户的定制内容怎么办？

A: 脚本会：
1. 检查文件是否已包含 attachment 引用
2. 如果缺失，在 Part 1 后添加（不覆盖用户的 Part 2 和 3）
3. 如果已存在，不做修改

### Q: 用户项目不是 Git 项目怎么办？

A: 脚本会：
1. 正常完成集成
2. 跳过 Git 提交（仅当 `--auto-commit` 时）
3. 提醒用户手动提交（如需要）

### Q: 用户可以定制某些技能吗？

A: 可以，通过创建 `.evolution-skills/skills-overrides/` 目录：
```
.evolution-skills/
├── skills/              (原始技能)
└── skills-overrides/
    └── _custom-skill/
        └── SKILL.md     (定制版本)
```
更新技能库时，overrides 不会被覆盖。

---

## AI 集成的决策树

```
用户请求集成
    ↓
检查参数和路径有效性
    ├─ 无效 → 显示错误并退出
    └─ 有效 ↓
创建目录结构
    ↓
复制 skills 和 constitution
    ↓
处理 copilot-instructions.md
    ├─ 文件不存在 → 创建新文件
    └─ 文件存在 ↓
       ├─ 已有 attachment → 保留
       └─ 缺失 attachment → 添加 Part 1
    ↓
创建 SKILLS_INTEGRATION_INFO.md
    ↓
验证集成
    ├─ 失败 → 显示错误，可选回滚
    └─ 成功 ↓
自动提交（如果 --auto-commit 且是 Git 项目）
    ↓
向用户报告成功
```

---

## 使用示例

### 例 1：新项目集成

```
用户：请把 copilot-evolution-skills 集成到 ~/my-new-project

AI 执行：
$ bash scripts/integrate-to-project.sh ~/my-new-project --auto-commit
✅ 集成完成！
   - 12 个技能已复制
   - 进化宪法已配置
   - copilot-instructions.md 已生成
   - 已自动提交

用户项目现在可以使用所有技能了！
```

### 例 2：现有项目补充集成

```
用户：我的项目 SilentFeed 也需要这些技能

AI 执行：
$ bash scripts/integrate-to-project.sh ~/develop/SilentFeed
✅ 集成完成！
   - 检测到已有 copilot-instructions.md
   - 保留了现有内容，仅添加 attachment 引用
   - 所有验证通过
```

### 例 3：更新技能库

```
用户：有新版本的技能库，请帮我更新

AI 执行：
$ bash .evolution-skills/scripts/update-integration.sh --backup
✅ 更新完成！
   - 已备份当前版本
   - 12 个技能已更新
   - 所有验证通过
   - 可以恢复到备份：.copilot/skills.backup.20260214_160000/
```

---

## 关键原则

1. **透明性** - 脚本输出清晰，用户知道发生了什么
2. **安全性** - 备份现有文件，不直接覆盖用户内容
3. **可靠性** - 完成每一步后验证，失败时清晰报错
4. **灵活性** - 支持新项目创建、现有项目补充、版本更新
5. **可恢复性** - 备份和 Git 历史保证可以回滚

---

> 💡 **AI 提示**：这份文档是你的工作指南。遇到集成相关的用户请求时，直接执行这里描述的脚本，无需向用户解释技术细节。你的职责是让集成过程对用户透明、简单、可靠。
