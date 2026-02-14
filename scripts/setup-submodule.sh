#!/bin/bash

# 一键集成脚本：将 copilot-evolution-skills 通过 submodule + sparse-checkout 集成到项目
# 使用方式：bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/setup-submodule.sh)

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_step() {
  echo -e "${BLUE}▶ $1${NC}"
}

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  copilot-evolution-skills 一键集成${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查是否在 git 项目中
if [ ! -d ".git" ]; then
  print_error "当前目录不是 git 项目"
  echo "请在你的项目根目录运行此脚本"
  exit 1
fi

print_step "第1步：添加 submodule"
git submodule add https://github.com/wxy/copilot-evolution-skills.git .copilot/skills
print_success "已添加 submodule"

echo ""
print_step "第2步：配置稀疏检出（节省空间）"

cd .copilot/skills

git config core.sparsecheckout true

# 创建稀疏检出配置
echo "skills/" >> .git/info/sparse-checkout
echo "constitution/" >> .git/info/sparse-checkout
echo "version.txt" >> .git/info/sparse-checkout

# 应用稀疏检出
git read-tree -mu HEAD

print_success "已配置稀疏检出"
cd ../..

echo ""
print_step "第3步：更新/创建 copilot-instructions.md"

INSTRUCTIONS_FILE=".github/copilot-instructions.md"

if [ ! -f "$INSTRUCTIONS_FILE" ]; then
  print_info "创建新的 copilot-instructions.md"
  mkdir -p .github
  
  cat > "$INSTRUCTIONS_FILE" << 'INSTRUCTIONS'
---
applyTo: "**"
---

# 项目指令

## Part 1: 通用框架 - AI 系统进化宪法

<attachment filePath=".copilot/skills/constitution/ai-evolution-constitution.md">
此部分包含了 AI 助手的通用进化框架。详见上述文件。该内容与具体项目无关，可独立维护和在多个项目中共享。
</attachment>

## Part 2: 项目特定规范

（此部分请根据你的项目需要补充）

## Part 3: 技能库说明

此项目已集成 copilot-evolution-skills（通用 AI 助手技能库），包含 12 个自定义技能。

可用技能列表：
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

INSTRUCTIONS

  print_success "已创建 copilot-instructions.md"
else
  print_info "copilot-instructions.md 已存在，保留原有内容"
  
  # 检查是否已有进化宪法引用
  if ! grep -q "ai-evolution-constitution.md" "$INSTRUCTIONS_FILE"; then
    print_info "⚠️  建议在 .github/copilot-instructions.md 的 Part 1 中添加进化宪法引用："
    echo ""
    echo "  <attachment filePath=\".copilot/skills/constitution/ai-evolution-constitution.md\">"
    echo "  此部分包含了 AI 助手的通用进化框架。详见上述文件。"
    echo "  </attachment>"
    echo ""
  fi
fi

echo ""
print_step "第4步：提交变更"

git add .gitmodules .github/copilot-instructions.md
git commit -m "feat: 集成 copilot-evolution-skills 技能库

- 添加 Git submodule (.copilot/skills)
- 配置稀疏检出 (仅下载 skills/ 和 constitution/)
- 创建/更新 .github/copilot-instructions.md
- 包含 12 个自定义技能和通用进化宪法框架"

print_success "已提交变更"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
print_success "集成完成！"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
echo "已完成的工作："
echo "  ✅ 添加 copilot-evolution-skills 作为 submodule"
echo "  ✅ 配置稀疏检出（节省空间）"
echo "  ✅ 创建/更新 .github/copilot-instructions.md"
echo "  ✅ 自动提交变更"
echo ""

echo "现在可用的 12 个技能："
echo "  • _evolution-core - 进化能力元技能"
echo "  • _typescript-type-safety - TypeScript Mock 创建与错误预防"
echo "  • _git-commit - Git 提交规范化"
echo "  • _pr-creator - PR 创建与版本控制流程"
echo "  • _code-health-check - 提交前代码检查"
echo "  • _release-process - 完整的发布流程"
echo "  • _context-ack - 上下文校验与输出格式"
echo "  • _instruction-guard - 强制读取指令文件"
echo "  • _file-output-guard - 文件创建安全约束"
echo "  • _change-summary - 提交摘要汇总"
echo "  • _traceability-check - 说明与变更校验"
echo "  • _session-safety - 会话超长防护"
echo ""

echo "下一步："
echo "  git push  # 推送代码到远程仓库"
echo ""
