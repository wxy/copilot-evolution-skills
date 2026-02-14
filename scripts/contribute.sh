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
if [ ! -e ".evolution-skills/.git" ]; then
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
cd .evolution-skills

# 检查是否有未提交的改动
HAS_UNCOMMITTED=false
if ! git diff-index --quiet HEAD --; then
  HAS_UNCOMMITTED=true
fi

# 检查是否领先于远程分支
git fetch origin main --quiet
AHEAD_COUNT=$(git rev-list --count origin/main..HEAD)

if [ "$HAS_UNCOMMITTED" = false ] && [ "$AHEAD_COUNT" -eq 0 ]; then
  print_info "没有检测到技能库的改动"
  echo "如果你想贡献新技能，请先在 .evolution-skills/ 中修改"
  exit 0
fi

# 显示改动
print_info "检测到技能库的改动"
if [ "$HAS_UNCOMMITTED" = true ]; then
  print_info "未提交的改动："
  git status --short
fi
if [ "$AHEAD_COUNT" -gt 0 ]; then
  print_info "领先远程 $AHEAD_COUNT 个提交："
  git log origin/main..HEAD --oneline
fi

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

# 如果有未提交的改动，需要先提交
if [ "$HAS_UNCOMMITTED" = true ]; then
  print_step "第3步：提交改动"
  echo ""
  read -p "请输入提交说明: " COMMIT_MSG
  git add .
  git commit -m "$COMMIT_MSG"
else
  print_info "改动已提交，跳过提交步骤"
fi

print_step "第4步：推送分支"
# Fork 并推送
git remote add fork "https://github.com/$(gh api user --jq .login)/copilot-evolution-skills.git" 2>/dev/null || true
git push fork "$BRANCH_NAME"

print_step "第5步：创建 PR"

# 获取提交信息作为 PR 标题和描述
COMMIT_SUBJECT=$(git log -1 --format=%s)
COMMIT_BODY=$(git log -1 --format=%b)
CHANGED_FILES=$(git show --name-only --format='' HEAD)

cd ../..

# 创建 PR
gh pr create \
  --repo wxy/copilot-evolution-skills \
  --title "$COMMIT_SUBJECT" \
  --body "### 贡献说明

$COMMIT_SUBJECT

${COMMIT_BODY:+$COMMIT_BODY

}### 来源项目

$(git remote get-url origin 2>/dev/null || echo "本地项目")

### 改动文件

\`\`\`
$CHANGED_FILES
\`\`\`

### 检查清单

- [x] 已测试改动
- [ ] 需要 review
" \
  --head "$(gh api user --jq .login):$BRANCH_NAME"

print_success "PR 创建成功！"
echo ""
echo "感谢你的贡献！维护者会尽快review。"
echo ""
