feat: 迁移 12 个自定义技能到独立项目

## 迁移内容
- _change-summary - 汇总提交摘要
- _code-health-check - 提交前代码检查
- _context-ack - 上下文校验与输出格式
- _evolution-core - 进化能力元技能
- _file-output-guard - 文件创建安全约束
- _git-commit - Git 提交规范化
- _instruction-guard - 强制读取指令文件
- _pr-creator - PR 创建与版本控制流程
- _release-process - 完整的发布流程
- _session-safety - 会话超长防护
- _traceability-check - 说明与变更校验
- _typescript-type-safety - TypeScript mock 与类型安全

## 迁移来源
从 SilentFeed 项目的 `.evolution-skills/` 目录完整复制

## 目录结构
```
skills/
├── _change-summary/SKILL.md
├── _code-health-check/SKILL.md
├── _context-ack/SKILL.md
├── _evolution-core/SKILL.md
├── _file-output-guard/SKILL.md
├── _git-commit/
│   ├── SKILL.md
│   └── references/  (commit 模板)
├── _instruction-guard/SKILL.md
├── _pr-creator/
│   └── SKILL.md
├── _release-process/SKILL.md
├── _session-safety/SKILL.md
├── _traceability-check/SKILL.md
└── _typescript-type-safety/SKILL.md
```

## 验证
- ✅ 所有 12 个技能目录完整复制
- ✅ 各技能的参考文件和资源保留
- ✅ 目录结构保持一致

## 下一步
- 编写技能库指南文档
- 编写模板文件
- 实现交互式安装脚本
- 测试 SilentFeed 中的 submodule 集成

---
> 🤖 本提交由 _git-commit 技能生成
