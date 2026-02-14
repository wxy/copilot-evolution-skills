#!/bin/bash

# 贡献脚本：将本地技能改进贡献回技能库
# 用法：bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/contribute.sh)

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
echo -e "${BLUE}  贡献技能改进${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查是否在 git 项目中
if [ ! -d ".git" ]; then
  print_error "当前目录不是 git 项目"
  exit 1
fi

# 检查 submodule 是否存在（.git 可能是文件或目录）
if [ ! -e ".copilot/skills/.git" ]; then
  print_error "未找到技能库 submodule"
  exit 1
fi

# 检查 gh CLI
if ! command -v gh &> /dev/null; then
  print_error "需要安装 GitHub CLI (gh)"
  echo "请访问: https://cli.github.com/"
  exit 1
fi

print_step "第1步：检查本地改动"
cd .copilot/skills

if ! git diff-index --quiet HEAD --; then
  print_info "检测到技能库的本地改动"
else
  print_info "没有检测到技能库的改动"
  echo "如果你想贡献新技能，请先在 .copilot/skills/ 中修改"
  exit 0
fi

# 显示改动
print_info "改动文件："
git status --short

echo ""
read -p "是否要将这些改动贡献回技能库？(y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  print_info "已取消"
  exit 0
fi

print_step "第2步：创建贡献分支"
BRANCH_NAME="contrib/$(date +%Y%m%d-%H%M%S)"
git checkout -b "$BRANCH_NAME"

print_step "第3步：提交改动"
echo ""
read -p "请输入提交说明: " COMMIT_MSG
git add .
git commit -m "$COMMIT_MSG"

print_step "第4步：推送分支"
# Fork 并推送
git remote add fork "https://github.com/$(gh api user --jq .login)/copilot-evolution-skills.git" 2>/dev/null || true
git push fork "$BRANCH_NAME"

print_step "第5步：创建 PR"
cd ../..

# 创建 PR
gh pr create \
  --repo wxy/copilot-evolution-skills \
  --title "$COMMIT_MSG" \
  --body "### 贡献说明

$COMMIT_MSG

### 来源项目

$(git remote get-url origin)

### 改动文件

$(cd .copilot/skills && git show --name-only --format='' HEAD)

### 检查清单

- [ ] 已测试改动
- [ ] 已更新相关文档
- [ ] 符合项目规范
" \
  --head "$(gh api user --jq .login):$BRANCH_NAME"

print_success "PR 创建成功！"
echo ""
echo "感谢你的贡献！维护者会尽快review。"
echo ""
