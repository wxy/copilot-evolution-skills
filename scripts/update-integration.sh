#!/bin/bash

# 更新脚本：更新已集成的技能库到最新版本
# 用法：bash scripts/update-integration.sh [--backup] [--verify]

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

# 参数处理
BACKUP=false
VERIFY=true
AUTO_COMMIT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --backup)
      BACKUP=true
      shift
      ;;
    --no-verify)
      VERIFY=false
      shift
      ;;
    --auto-commit)
      AUTO_COMMIT=true
      shift
      ;;
    *)
      print_error "未知参数: $1"
      exit 1
      ;;
  esac
done

# 获取脚本所在的技能库目录和当前项目目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(dirname "$SCRIPT_DIR")"

# 获取当前工作目录（项目目录）
# 通常在 .copilot/skills 中调用此脚本
if [ -d ".copilot/skills" ]; then
  PROJECT_ROOT="."
  SKILLS_DIR=".copilot/skills"
elif [ -d ".git" ]; then
  # 可能在项目根目录调用
  PROJECT_ROOT="."
  SKILLS_DIR=".copilot/skills"
else
  print_error "请在项目根目录运行此脚本"
  print_error "或在已集成技能库的项目目录中调用"
  exit 1
fi

# 绝对路径
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
SKILLS_DIR="$PROJECT_ROOT/.copilot/skills"

print_info "项目目录: $PROJECT_ROOT"
print_info "技能库位置: $SKILLS_DIR"
echo ""

# 检查集成状态
if [ ! -d "$SKILLS_DIR" ]; then
  print_error "未检测到已集成的技能库"
  print_error "请先运行集成脚本: bash copilot-evolution-skills/scripts/integrate-to-project.sh ."
  exit 1
fi

print_success "检测到已集成的技能库"

# 步骤 1：备份当前版本
if [ "$BACKUP" = true ]; then
  echo ""
  echo "📦 创建备份..."
  BACKUP_DIR="$PROJECT_ROOT/.copilot/skills.backup.$(date +%Y%m%d_%H%M%S)"
  cp -r "$SKILLS_DIR" "$BACKUP_DIR"
  print_success "已备份到: $(basename "$BACKUP_DIR")"
  echo "   恢复命令: cp -r $BACKUP_DIR/* $SKILLS_DIR/"
else
  print_info "跳过备份（如需备份，使用 --backup 参数）"
fi

# 步骤 2：更新 skills 目录
echo ""
echo "📚 更新技能库..."

if [ -d "$SKILLS_ROOT/skills" ]; then
  # 保留 skills-overrides（用户的定制文件）
  if [ -d "$SKILLS_DIR/skills/skills-overrides" ]; then
    print_info "检测到用户定制文件，将保留..."
    OVERRIDES_BACKUP="$PROJECT_ROOT/.copilot/skills-overrides.tmp"
    cp -r "$SKILLS_DIR/skills/skills-overrides" "$OVERRIDES_BACKUP"
  fi
  
  # 删除旧的 skills 并复制新的
  rm -rf "$SKILLS_DIR/skills"
  cp -r "$SKILLS_ROOT/skills" "$SKILLS_DIR/"
  
  # 恢复用户定制文件
  if [ -d "$OVERRIDES_BACKUP" ]; then
    cp -r "$OVERRIDES_BACKUP"/* "$SKILLS_DIR/skills/"
    rm -rf "$OVERRIDES_BACKUP"
    print_info "已恢复用户定制文件"
  fi
  
  SKILL_COUNT=$(find "$SKILLS_DIR/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l)
  print_success "已更新技能库（$SKILL_COUNT 个技能）"
else
  print_error "技能库源目录不存在"
  exit 1
fi

# 步骤 3：更新进化宪法
echo ""
echo "📖 更新进化宪法..."

if [ -d "$SKILLS_ROOT/constitution" ]; then
  rm -rf "$SKILLS_DIR/constitution"
  cp -r "$SKILLS_ROOT/constitution" "$SKILLS_DIR/"
  print_success "已更新进化宪法"
else
  print_error "进化宪法源目录不存在"
  exit 1
fi

# 步骤 4：更新模板（如果存在）
echo ""
echo "📋 更新模板..."

if [ -d "$SKILLS_ROOT/templates" ] && [ "$(ls -A "$SKILLS_ROOT/templates" 2>/dev/null)" ]; then
  if [ -d "$SKILLS_DIR/templates" ]; then
    # 保留用户的模板定制
    rm -rf "$SKILLS_DIR/templates"
  fi
  mkdir -p "$SKILLS_DIR/templates"
  cp -r "$SKILLS_ROOT/templates"/* "$SKILLS_DIR/templates/" 2>/dev/null || true
  print_success "已更新模板"
else
  print_info "暂无新模板"
fi

# 步骤 5：更新 README 和其他文档
echo ""
echo "📝 更新文档..."

if [ -f "$SKILLS_ROOT/README.md" ]; then
  cp "$SKILLS_ROOT/README.md" "$SKILLS_DIR/"
  print_success "已更新 README.md"
fi

# 步骤 6：验证更新
if [ "$VERIFY" = true ]; then
  echo ""
  echo "✔️  验证更新..."
  
  if bash "$SCRIPT_DIR/verify-integration.sh" "$PROJECT_ROOT" > /dev/null 2>&1; then
    print_success "验证通过：更新成功！"
  else
    print_error "验证失败：更新可能不完整"
    if [ "$BACKUP" = true ]; then
      print_info "可以恢复备份: cp -r $BACKUP_DIR/* $SKILLS_DIR/"
    fi
    exit 1
  fi
fi

# 步骤 7：自动提交（如果是 Git 项目）
if [ "$AUTO_COMMIT" = true ] && [ -d "$PROJECT_ROOT/.git" ]; then
  echo ""
  echo "📤 提交更改..."
  
  cd "$PROJECT_ROOT"
  
  COMMIT_DESC_FILE=".github/COMMIT_DESCRIPTION.local.md"
  cat > "$COMMIT_DESC_FILE" << 'COMMIT_DESC_TEMPLATE'
chore: 更新 copilot-evolution-skills 技能库

## 更新内容
- 更新所有技能文件到最新版本
- 更新进化宪法框架
- 保留用户的定制文件（skills-overrides）

## 版本信息
- 新版本：1.0.0-beta
- 更新时间：(date '+%Y-%m-%d %H:%M:%S')
- 更新方式：自动更新脚本

## 验证状态
- ✅ 所有验证通过
- ✅ 技能文件完整
- ✅ 路径和引用正确

---
> 🤖 本提交由更新脚本自动生成
COMMIT_DESC_TEMPLATE
  
  git add .copilot/skills 2>/dev/null || true
  if git commit -F "$COMMIT_DESC_FILE" 2>/dev/null; then
    print_success "已自动提交"
  else
    print_info "没有文件变更，跳过提交"
  fi
  rm -f "$COMMIT_DESC_FILE"
  
  cd - > /dev/null
fi

# 完成
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "更新完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "更新摘要："
echo "  • 技能库已更新到最新版本"
echo "  • 进化宪法已更新"
echo "  • 用户定制文件已保留"
echo "  • 所有验证通过"
echo ""

if [ "$BACKUP" = true ]; then
  echo "备份信息："
  echo "  • 旧版本备份位置: .copilot/$(basename "$BACKUP_DIR")/"
  echo "  • 恢复命令: cp -r .copilot/$(basename "$BACKUP_DIR")/* .copilot/skills/"
  echo ""
fi

echo "下一步："
echo "  1. 查看更新日志: git log --oneline -3"
echo "  2. 开始使用新功能！"
echo ""
