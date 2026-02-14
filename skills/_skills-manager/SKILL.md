# 技能：可进化技能库管理器

## 概述

用于管理 copilot-evolution-skills 技能库的更新、贡献和维护。当用户请求"更新技能"、"贡献技能"或"检查技能版本"时使用。

## 触发条件

- "更新可进化技能" / "update skills"
- "贡献技能改进" / "contribute skills"
- "检查技能版本" / "check skills version"
- "同步最新技能" / "sync skills"
- "提交技能进化" / "submit skill improvements"

## 执行流程

### 1. 更新技能库

当用户要求更新技能时：

```bash
# 执行远程更新脚本
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/update.sh)
```

**脚本会自动处理**：
- 暂存当前工作
- 拉取最新 main 分支
- 尝试合并（如失败则 rebase）
- 处理冲突
- 提交更新

**冲突处理**：
如果出现冲突，脚本会提示：
1. **本地优先**：保留你的改进（适用于你做了增强的情况）
2. **远程优先**：使用最新版本（适用于你未修改的情况）
3. **手动合并**：复杂情况下需人工决策

### 2. 贡献技能改进

当用户要求贡献本地改进时：

**前置条件检查**：
```bash
# 检查是否有本地修改
cd .copilot/skills
git status --short
```

如果有修改，执行贡献脚本：

```bash
# 执行远程贡献脚本
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/contribute.sh)
```

**脚本会自动处理**：
- 检查本地变更
- 创建贡献分支（格式：`contrib-<timestamp>`）
- 推送到 fork（如无 fork 会提示创建）
- 使用 `gh` CLI 创建 PR
- PR 标题：`feat: 用户贡献的技能改进`
- PR 描述：自动生成变更列表

**必需工具**：
- GitHub CLI (`gh`)：用于创建 PR
- 如未安装：`brew install gh`（macOS）

### 3. 检查技能版本

验证当前使用的技能库版本：

```bash
cd .copilot/skills
cat version.txt
git log -1 --format="%H %s"
```

显示：
- 版本标识（version.txt）
- 最新提交哈希和消息

### 4. 验证技能完整性

检查技能库是否正确配置：

```bash
# 检查 submodule 状态
git submodule status

# 检查稀疏检出配置
cd .copilot/skills
cat $(cat .git | sed 's/gitdir: //')/info/sparse-checkout

# 列出可用技能
ls -1 skills/
```

## 常见问题处理

### Q: 更新失败，提示"本地有未提交的修改"

**解决方案**：
```bash
cd .copilot/skills
git stash
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/update.sh)
git stash pop  # 如需恢复本地修改
```

### Q: 贡献脚本提示"无本地 fork"

**解决方案**：
```bash
# 1. Fork 仓库到你的账号
gh repo fork wxy/copilot-evolution-skills --clone=false

# 2. 添加 fork 为远程仓库
cd .copilot/skills
git remote add fork https://github.com/YOUR_USERNAME/copilot-evolution-skills.git

# 3. 重新运行贡献脚本
```

### Q: 如何查看技能库的更新历史？

```bash
cd .copilot/skills
git log --oneline --graph -10
```

### Q: 更新后发现某个技能有问题，如何回滚？

```bash
cd .copilot/skills
git log --oneline  # 找到回滚目标版本
git checkout <commit-hash>
cd ../..
git add .copilot/skills
git commit -m "fix: 回滚技能库到稳定版本"
```

## 最佳实践

### 更新频率建议

- **定期更新**：每周或每次开始新会话时
- **主动触发**：当听说有新技能或修复时
- **自动提醒**：可设置 GitHub Actions 监控更新

### 贡献准则

**应该贡献的改进**：
✅ 修复技能中的错误
✅ 增强技能的清晰度
✅ 添加新的边界案例处理
✅ 改进执行流程
✅ 补充最佳实践

**不应贡献的修改**：
❌ 项目特定的定制
❌ 个人偏好的风格调整
❌ 未经测试的实验性修改

### 贡献前检查清单

- [ ] 本地测试过改进（实际使用验证）
- [ ] 改进具有通用性（不限于特定项目）
- [ ] 文档清晰（AI 能理解执行）
- [ ] 遵循现有技能的格式规范

## 技能自举（Self-Hosting）

这个技能本身也是可进化的！当你改进了这个管理技能时：

```bash
# 1. 编辑 .copilot/skills/skills/_skills-manager/SKILL.md
# 2. 测试改进
# 3. 使用本技能贡献自己
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/contribute.sh)
```

## 示例对话

**用户**: "更新可进化技能"

**AI 执行**:
1. 运行 `update.sh` 脚本
2. 报告更新结果（新增/修改的技能）
3. 如有冲突，提供解决建议

---

**用户**: "我改进了 _git-commit 技能，贡献回去"

**AI 执行**:
1. 检查 `.copilot/skills/` 的修改
2. 运行 `contribute.sh` 脚本
3. 创建 PR 并提供链接
4. 提示等待 review

---

**用户**: "检查当前技能库版本"

**AI 执行**:
1. 显示 version.txt 内容
2. 显示最新提交信息
3. 列出可用技能数量

## 技术说明

- **Submodule 管理**：技能库作为 Git submodule 集成
- **稀疏检出**：仅下载 `skills/`、`constitution/`、`version.txt`
- **远程脚本**：始终使用 GitHub 最新版本（确保流程一致性）
- **分支策略**：贡献使用 `contrib-*` 分支，避免污染 main

## 相关资源

- 技能库仓库：https://github.com/wxy/copilot-evolution-skills
- 集成文档：仓库 README.md
- 其他脚本：`setup.sh`（初次集成）

## 快速参考

### 常用命令

- 更新技能：`bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/update.sh)`
- 贡献改进：`bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/contribute.sh)`
- 检查版本：`cat .copilot/skills/version.txt`


## 快速参考

### 常用命令

- 更新技能：`bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/update.sh)`
- 贡献改进：`bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/contribute.sh)`
- 检查版本：`cat .copilot/skills/version.txt`
