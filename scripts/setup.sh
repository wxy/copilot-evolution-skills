#!/bin/bash

# 一键集成脚本：将 copilot-evolution-skills 通过 submodule + sparse-checkout 集成到项目
# 使用方式：bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/setup.sh)

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
if [ -e ".evolution-skills/.git" ] || grep -q "copilot-evolution-skills" .gitmodules 2>/dev/null; then
  print_info "检测到已存在的 submodule，切换为更新流程"
  bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/update.sh)
  exit 0
else
  git submodule add https://github.com/wxy/copilot-evolution-skills.git .evolution-skills
  print_success "已添加 submodule"
fi

echo ""
print_step "第2步：配置稀疏检出（节省空间）"

cd .evolution-skills

# 配置稀疏检出
git config core.sparseCheckout true

# 获取 git 目录（submodule 的 .git 可能是文件）
if [ -f .git ]; then
  GIT_DIR=$(cat .git | sed 's/gitdir: //')
  SPARSE_CHECKOUT_FILE="$GIT_DIR/info/sparse-checkout"
else
  SPARSE_CHECKOUT_FILE=".git/info/sparse-checkout"
fi

# 创建目录（如果不存在）
mkdir -p "$(dirname "$SPARSE_CHECKOUT_FILE")"

# 创建稀疏检出配置
printf "skills/\nconstitution/\nversion.txt\n" > "$SPARSE_CHECKOUT_FILE"

# 应用稀疏检出
git read-tree -mu HEAD

print_success "已配置稀疏检出"
cd ..

echo ""
print_step "第3步：更新/创建 copilot-instructions.md"

INSTRUCTIONS_FILE=".github/copilot-instructions.md"

if [ ! -f "$INSTRUCTIONS_FILE" ]; then
  print_info "创建新的 copilot-instructions.md"
  mkdir -p .github
  
  printf '%s\n' \
    '---' \
    'applyTo: "**"' \
    '---' \
    '' \
    '# 项目指令' \
    '' \
    '## Part 1: 强制执行' \
    '' \
    '**⚠️ 在开始任何工作前，必须读取并完全理解执行**：' \
    '[../.evolution-skills/constitution/ai-evolution-constitution.md](../.evolution-skills/constitution/ai-evolution-constitution.md)' \
    '' \
    '## Part 2: 项目特定规范' \
    '' \
    '（此部分请根据你的项目需要补充）' \
    '' \
    '## Part 3: 技能库说明' \
    '' \
    '此项目已集成 copilot-evolution-skills（通用 AI 助手技能库）。' \
    '' \
    '技能位置：`.evolution-skills/skills/`' \
    '' \
    > "$INSTRUCTIONS_FILE"

  print_success "已创建 copilot-instructions.md"
else
  print_info "copilot-instructions.md 已存在，保留原有内容"
  
  # 检查并修正宪法引用路径
  if grep -q "ai-evolution-constitution.md" "$INSTRUCTIONS_FILE"; then
    # 检查路径是否正确
    if ! grep -q "\.\./\.evolution-skills/constitution/ai-evolution-constitution.md" "$INSTRUCTIONS_FILE"; then
      print_info "检测到宪法引用路径错误，正在修正..."
      # 修正各种可能的错误路径格式
      sed -i.bak 's|\.github/ai-evolution-constitution\.md|../.evolution-skills/constitution/ai-evolution-constitution.md|g' "$INSTRUCTIONS_FILE"
      sed -i.bak 's|\.copilot[^"]*ai-evolution-constitution\.md|../.evolution-skills/constitution/ai-evolution-constitution.md|g' "$INSTRUCTIONS_FILE"
      sed -i.bak 's|\.evolution-skills/ai-evolution-constitution\.md|../.evolution-skills/constitution/ai-evolution-constitution.md|g' "$INSTRUCTIONS_FILE"
      sed -i.bak 's|\.evolution-skills/constitution/ai-evolution-constitution\.md|../.evolution-skills/constitution/ai-evolution-constitution.md|g' "$INSTRUCTIONS_FILE"
      rm -f "$INSTRUCTIONS_FILE.bak"
      print_success "已修正宪法引用路径"
    else
      print_info "宪法引用路径正确"
    fi
  else
    print_info "⚠️  建议在 .github/copilot-instructions.md 的 Part 1 中添加进化宪法引用："
    echo ""
    echo "  **⚠️ 在开始任何工作前，必须读取并完全理解执行**："
    echo "  [../.evolution-skills/constitution/ai-evolution-constitution.md](../.evolution-skills/constitution/ai-evolution-constitution.md)"
    echo ""
  fi

fi

echo ""
print_step "第3.5步：更新 AGENTS.md（如果存在）"

if [ -f "AGENTS.md" ]; then
  if grep -q "<!-- PROJECT_SKILLS_START -->" AGENTS.md; then
    print_info "检测到 AGENTS.md，正在更新技能引用..."

    SKILLS_CONTENT_FILE=$(mktemp)
    printf '%s\n' \
      '<!-- 可进化技能从 copilot-evolution-skills 仓库集成: https://github.com/wxy/copilot-evolution-skills -->' \
      '<!-- 通过 Git Submodule 自动同步，使用 update.sh 可获取最新版本 -->' \
      '' \
      '<project_skills>' \
      > "$SKILLS_CONTENT_FILE"

    for skill_dir in .evolution-skills/skills/_*; do
      if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        skill_file="$skill_dir/SKILL.md"
        if [ -f "$skill_file" ]; then
          description=$(grep -m 1 -E '^description:' "$skill_file" | sed 's/^description:[[:space:]]*//')
          if [ -z "$description" ]; then
            description=$(grep -A 2 '^## 概述' "$skill_file" | tail -n 1 | sed 's/^[[:space:]]*//')
          fi
          [ -z "$description" ] && description="可进化技能"

          printf '<skill>\n<name>%s</name>\n<description>%s</description>\n<file>.evolution-skills/skills/%s/SKILL.md</file>\n</skill>\n\n' \
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
print_step "第4步：提交变更"

# 调试信息
print_info "当前目录: $(pwd)"
print_info "检查 git 状态..."
test -d .git && echo "  ✓ .git 目录存在" || echo "  ✗ .git 目录不存在"

# 添加文件（包括可能被修改的 AGENTS.md）
git add .gitmodules .evolution-skills .github/copilot-instructions.md AGENTS.md 2>/dev/null || git add .gitmodules .evolution-skills .github/copilot-instructions.md
git commit -m "feat: 集成 copilot-evolution-skills 技能库

- 添加 Git submodule (.evolution-skills/skills)
- 配置稀疏检出 (仅下载 skills/ 和 constitution/)
- 创建/更新 .github/copilot-instructions.md
- 包含可复用技能和通用进化宪法框架"

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

echo "技能库位置："
echo "  .evolution-skills/skills/"
echo ""

echo "下一步："
echo "  git push  # 推送代码到远程仓库"
echo ""
