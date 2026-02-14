# CHANGELOG

所有对本项目的重要变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/)，采用 [Semantic Versioning](https://semver.org/) 版本号。

---

## [1.0.0-beta] - 2026-02-14

### Added
- 🎉 **初始化 copilot-evolution-skills 项目** - 通用 AI 助手技能库
- 📚 **完整的项目文档**
  - README.md - 项目主页和快速指南
  - SETUP.md - 安装和使用说明
  - constitution/ai-evolution-constitution.md - 通用进化宪法
- 🛠️ **12 个自定义技能的迁移**
  - _evolution-core - 进化能力元技能
  - _typescript-type-safety - TypeScript Mock 创建与错误预防
  - _git-commit - Git 提交规范化
  - _pr-creator - PR 创建与版本控制流程
  - _code-health-check - 提交前代码检查
  - _release-process - 完整的发布流程
  - _context-ack - 上下文校验与输出格式
  - _instruction-guard - 强制读取指令文件
  - _file-output-guard - 文件创建安全约束
  - _change-summary - 提交摘要汇总
  - _traceability-check - 说明与变更校验
  - _session-safety - 会话超长防护

### In Progress
- 🔄 **核心文档编写中**
  - .github/INSTALLATION.md - AI 参考指南
  - .github/CONFLICT_RESOLUTION.md - 多项目冲突处理
  - .github/EVOLUTION.md - 技能演进机制
  - docs/AI_INTEGRATION_GUIDE.md - AI 集成指南
  - docs/SKILL_CREATION_GUIDE.md - 新技能创建流程
  - docs/MULTI_PROJECT_GUIDE.md - 多项目共享指南
  - docs/VERSIONING.md - 版本管理策略

- 🛠️ **工具脚本编写中**
  - scripts/setup-interactive.sh - 交互式安装脚本
  - scripts/validate-installation.sh - 安装验证脚本
  - scripts/resolve-conflicts.sh - 冲突解决辅助脚本

- 📋 **模板编写中**
  - templates/SKILL_TEMPLATE.md - 新技能标准模板
  - templates/INSTRUCTION_TEMPLATE.md - 项目指令模板
  - templates/copilot-instructions-base.md - 指令基础模板

### Future Plans
- 与 SilentFeed 项目的 submodule 集成测试
- 在多个项目中验证冲突解决方案
- 完整的 API 文档
- GitHub Actions 持续集成

---

## 版本说明

### 当前版本：1.0.0-beta
- **状态**：设计完成，初始化完成，文档和工具编写进行中
- **预计完成**：2026 年 3 月
- **目标**：v1.0.0（稳定版本，支持多项目集成）

### 版本管理策略

采用 Semantic Versioning：

- **MAJOR** (主版本)：架构变化（文件结构、用法改变）
  - 示例：1.0.0 → 2.0.0（需要项目重新适配）
  
- **MINOR** (次版本)：新技能、主要改进（向后兼容）
  - 示例：1.0.0 → 1.1.0（自动升级安全）
  
- **PATCH** (修订版本)：文档更新、小修复（向后兼容）
  - 示例：1.0.0 → 1.0.1（自动升级推荐）

### 发布流程

1. 创建 release/* 分支
2. 更新版本号（version.txt）
3. 更新 CHANGELOG.md
4. 创建 PR 进行审查
5. 合并到 master
6. 标记 Git tag：`git tag v1.0.0`
7. 发布 GitHub Release
8. 项目通过 `git submodule update --remote` 获取更新

---

## 贡献指南

如果你想为本项目贡献新技能或改进：

1. 阅读 [docs/SKILL_CREATION_GUIDE.md](./docs/SKILL_CREATION_GUIDE.md)
2. 遵循技能模板创建新技能
3. 创建 PR，描述技能的目的和应用场景
4. 获得至少 2 个 Reviewer 的批准
5. 合并并更新版本号和 CHANGELOG

---

## 相关链接

- 📖 [README.md](./README.md) - 项目主页
- 🚀 [SETUP.md](./SETUP.md) - 快速开始
- 🛠️ [docs/](./docs/) - 详细文档
- 📚 [constitution/ai-evolution-constitution.md](./constitution/ai-evolution-constitution.md) - 进化宪法
- 🎯 [skills/](./skills/) - 所有技能库

---

## 许可证

本项目采用 MIT License - 详见 [LICENSE](./LICENSE) 文件
