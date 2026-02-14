#!/bin/bash

# 验证脚本：验证技能库集成的完整性
# 用法：bash scripts/verify-integration.sh <project-path> [--verbose]

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

# 检查参数
if [ -z "$1" ]; then
  print_error "用法: bash verify-integration.sh <project-path> [--verbose]"
  echo ""
  echo "参数说明:"
  echo "  <project-path>   用户项目的根目录（必需）"
  echo "  --verbose        详细输出模式"
  exit 1
fi

TARGET_PROJECT="$1"
VERBOSE=false

if [ "$2" == "--verbose" ]; then
  VERBOSE=true
fi

# 验证目标项目路径
if [ ! -d "$TARGET_PROJECT" ]; then
  print_error "项目目录不存在: $TARGET_PROJECT"
  exit 1
fi

SKILLS_DIR="$TARGET_PROJECT/.copilot/skills"
INTEGRATION_INFO="$TARGET_PROJECT/.github/SKILLS_INTEGRATION_INFO.md"
INSTRUCTIONS_FILE="$TARGET_PROJECT/.github/copilot-instructions.md"

ERRORS=0
WARNINGS=0
PASSED=0

# 打印报告头
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "验证报告 - $TARGET_PROJECT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 1：目录结构
echo "🔍 检查目录结构..."
if [ ! -d "$SKILLS_DIR" ]; then
  print_error "缺失 .copilot/skills 目录"
  ((ERRORS++))
else
  print_success ".copilot/skills 目录存在"
  ((PASSED++))
fi

if [ ! -d "$SKILLS_DIR/skills" ]; then
  print_error "缺失 .copilot/skills/skills 目录"
  ((ERRORS++))
else
  print_success ".copilot/skills/skills 目录存在"
  ((PASSED++))
fi

if [ ! -d "$SKILLS_DIR/constitution" ]; then
  print_error "缺失 .copilot/skills/constitution 目录"
  ((ERRORS++))
else
  print_success ".copilot/skills/constitution 目录存在"
  ((PASSED++))
fi

# 检查 2：技能文件
echo ""
echo "🔍 检查技能文件..."
SKILL_COUNT=$(find "$SKILLS_DIR/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l)

if [ "$SKILL_COUNT" -eq 12 ]; then
  print_success "12 个技能文件完整"
  ((PASSED++))
  
  if [ "$VERBOSE" = true ]; then
    find "$SKILLS_DIR/skills" -name "SKILL.md" -type f | sed 's|.*skills/||;s|/SKILL.md||' | sort | while read skill; do
      echo "    • $skill"
    done
  fi
else
  print_error "技能文件不完整：期望 12 个，实际 $SKILL_COUNT 个"
  ((ERRORS++))
fi

# 检查 3：进化宪法
echo ""
echo "🔍 检查进化宪法..."
CONSTITUTION_FILE="$SKILLS_DIR/constitution/ai-evolution-constitution.md"

if [ ! -f "$CONSTITUTION_FILE" ]; then
  print_error "缺失进化宪法文件"
  ((ERRORS++))
else
  if [ -r "$CONSTITUTION_FILE" ]; then
    print_success "进化宪法文件存在且可读"
    ((PASSED++))
    
    if [ "$VERBOSE" = true ]; then
      CONST_LINES=$(wc -l < "$CONSTITUTION_FILE")
      echo "    • 文件行数: $CONST_LINES"
    fi
  else
    print_error "进化宪法文件不可读"
    ((ERRORS++))
  fi
fi

# 检查 4：copilot-instructions.md
echo ""
echo "🔍 检查项目指令文件..."
if [ ! -f "$INSTRUCTIONS_FILE" ]; then
  print_error "缺失 .github/copilot-instructions.md"
  ((ERRORS++))
else
  print_success ".github/copilot-instructions.md 存在"
  ((PASSED++))
  
  # 检查 Markdown 语法（简单检查）
  if grep -q "^#" "$INSTRUCTIONS_FILE"; then
    print_success "Markdown 格式检查通过"
    ((PASSED++))
  else
    print_error "Markdown 格式异常"
    ((ERRORS++))
  fi
  
  # 检查 attachment 引用
  if grep -q "attachment filePath=" "$INSTRUCTIONS_FILE"; then
    print_success "attachment 引用存在"
    ((PASSED++))
    
    if grep -q "attachment filePath=\".copilot/skills/constitution/ai-evolution-constitution.md\"" "$INSTRUCTIONS_FILE"; then
      print_success "attachment 引用路径正确"
      ((PASSED++))
    else
      print_error "attachment 引用路径不正确"
      ((ERRORS++))
    fi
  else
    print_error "缺失 attachment 引用"
    ((ERRORS++))
  fi
fi

# 检查 5：集成信息文件
echo ""
echo "🔍 检查集成信息文件..."
if [ ! -f "$INTEGRATION_INFO" ]; then
  print_error "缺失 .github/SKILLS_INTEGRATION_INFO.md"
  ((ERRORS++))
else
  print_success ".github/SKILLS_INTEGRATION_INFO.md 存在"
  ((PASSED++))
  
  if [ "$VERBOSE" = true ]; then
    if grep -q "集成日期" "$INTEGRATION_INFO"; then
      INTEGRATION_DATE=$(grep "集成日期" "$INTEGRATION_INFO" | cut -d: -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      echo "    • 集成日期: $INTEGRATION_DATE"
    fi
  fi
fi

# 检查 6：没有冲突或重复
echo ""
echo "🔍 检查潜在冲突..."
BACKUP_COUNT=$(find "$TARGET_PROJECT/.copilot" -name "skills.backup.*" -type d 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt 0 ]; then
  print_info "检测到 $BACKUP_COUNT 个备份目录"
  if [ "$VERBOSE" = true ]; then
    find "$TARGET_PROJECT/.copilot" -name "skills.backup.*" -type d | while read backup; do
      echo "    • $(basename "$backup")"
    done
  fi
  ((WARNINGS++))
fi

# 总结报告
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "验证总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ 通过: $PASSED"
echo "⚠️  警告: $WARNINGS"
echo "❌ 错误: $ERRORS"
echo ""

if [ "$ERRORS" -eq 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_success "所有验证通过！项目已就绪使用所有技能"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_error "验证失败，请检查上述错误"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
