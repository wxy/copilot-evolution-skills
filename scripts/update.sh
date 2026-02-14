#!/bin/bash

# 更新脚本：更新用户项目中的技能库
# 用法：bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/update.sh)

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
echo -e "${BLUE}  copilot-evolution-skills 更新${NC}"
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
  echo "请先运行 setup.sh 集成技能库"
  exit 1
fi

print_step "第1步：保存当前工作状态"
if ! git diff-index --quiet HEAD --; then
  print_info "检测到未提交的更改，正在保存..."
  git stash push -m "auto-stash before skills update"
  STASHED=true
else
  STASHED=false
fi

print_step "第2步：更新技能库"
cd .copilot/skills

# 获取当前版本
CURRENT_VERSION=$(git rev-parse HEAD | cut -c1-8)
print_info "当前版本: $CURRENT_VERSION"

# 更新到最新
git fetch origin main
LATEST_VERSION=$(git rev-parse origin/main | cut -c1-8)
print_info "最新版本: $LATEST_VERSION"

if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
  print_success "已是最新版本"
  cd ../..
  if [ "$STASHED" = true ]; then
    git stash pop
  fi
  exit 0
fi

# 尝试合并
print_step "第3步：合并更新"
if git merge origin/main --no-edit; then
  print_success "成功合并更新"
  MERGE_SUCCESS=true
else
  print_info "检测到冲突，尝试衍合..."
  git merge --abort
  
  if git rebase origin/main; then
    print_success "成功衍合更新"
    MERGE_SUCCESS=true
  else
    print_error "自动合并失败，需要手动处理"
    print_info "冲突文件："
    git diff --name-only --diff-filter=U
    echo ""
    echo "请手动解决冲突后运行："
    echo "  git add ."
    echo "  git rebase --continue"
    echo "  cd ../.."
    echo "  git commit -am 'chore: 更新技能库'"
    exit 1
  fi
fi

cd ../..

print_step "第3.5步：更新 AGENTS.md（如果存在）"

if [ -f "AGENTS.md" ]; then
  if grep -q "<!-- PROJECT_SKILLS_START -->" AGENTS.md; then
    print_info "检测到 AGENTS.md，正在更新技能引用..."

    SKILLS_CONTENT_FILE=$(mktemp)
    printf '%s\n' \
      '<!-- 项目自定义技能现在从远程 GitHub 仓库集成: https://github.com/wxy/copilot-evolution-skills -->' \
      '<!-- 可进化技能已移至独立项目，通过远程脚本进行管理 -->' \
      '' \
      '<project_skills>' \
      > "$SKILLS_CONTENT_FILE"

    for skill_dir in .copilot/skills/skills/_*; do
      if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        skill_file="$skill_dir/SKILL.md"
        if [ -f "$skill_file" ]; then
          description=$(grep -m 1 -E '^description:' "$skill_file" | sed 's/^description:[[:space:]]*//')
          if [ -z "$description" ]; then
            description=$(grep -A 2 '^## 概述' "$skill_file" | tail -n 1 | sed 's/^[[:space:]]*//')
          fi
          [ -z "$description" ] && description="可进化技能"

          printf '<skill>\n<name>%s</name>\n<description>%s</description>\n<file>.copilot/skills/skills/%s/SKILL.md</file>\n</skill>\n\n' \
            "$skill_name" "$description" "$skill_name" \
            >> "$SKILLS_CONTENT_FILE"
        fi
      fi
    done

    printf '%s\n' '</project_skills>' >> "$SKILLS_CONTENT_FILE"

    SKILLS_CONTENT_FILE="$SKILLS_CONTENT_FILE" \
    python -c 'import os,re,pathlib; path=pathlib.Path("AGENTS.md"); data=path.read_text(); start="<!-- PROJECT_SKILLS_START -->"; end="<!-- PROJECT_SKILLS_END -->"; content=pathlib.Path(os.environ["SKILLS_CONTENT_FILE"]).read_text(); pattern=re.compile(re.escape(start)+r".*?"+re.escape(end), re.S); new=start+"\n"+content+"\n"+end; path.write_text(pattern.sub(new, data))'

    rm "$SKILLS_CONTENT_FILE"
    print_success "已更新 AGENTS.md"
  else
    print_info "AGENTS.md 没有 PROJECT_SKILLS 标记，跳过更新"
  fi
else
  print_info "未找到 AGENTS.md 文件，跳过更新"
fi

echo ""
print_step "第4步：提交更新"
git add .copilot/skills
git commit -m "chore: 更新 copilot-evolution-skills 到 $LATEST_VERSION"

if [ "$STASHED" = true ]; then
  print_info "恢复之前的工作状态..."
  git stash pop
fi

print_success "更新完成！"
echo ""
echo "版本变化: $CURRENT_VERSION → $LATEST_VERSION"
echo ""
echo "下一步："
echo "  git push  # 推送更新"
echo ""
