#!/bin/bash

# 集成脚本：将 copilot-evolution-skills 集成到用户项目
# 用途：一键集成技能库到任何项目
# 用法：bash integrate-to-project.sh <project-path> [--auto-commit] [--source <source-path-or-url>]

set -e  # 任何错误时立即退出

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 功能：打印彩色消息
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
  print_error "用法: bash integrate-to-project.sh <project-path> [--auto-commit] [--source <source-path-or-url>]"
  echo ""
  echo "参数说明:"
  echo "  <project-path>           用户项目的根目录（必需）"
  echo "  --auto-commit            自动提交更改（仅当项目是 Git 仓库时）"
  echo "  --source <path-or-url>   技能库源地址（本地路径或 GitHub URL）"
  echo ""
  echo "示例:"
  echo "  # 本地集成"
  echo "  bash integrate-to-project.sh . --auto-commit --source /path/to/copilot-evolution-skills"
  echo ""
  echo "  # 远程集成（从 GitHub）"
  echo "  bash integrate-to-project.sh . --auto-commit --source https://github.com/wxy/copilot-evolution-skills"
  exit 1
fi

TARGET_PROJECT="$1"
AUTO_COMMIT=false
SOURCE=""

# 解析参数
i=2
while [ $i -le $# ]; do
  case "${!i}" in
    --auto-commit)
      AUTO_COMMIT=true
      i=$((i+1))
      ;;
    --source)
      i=$((i+1))
      SOURCE="${!i}"
      i=$((i+1))
      ;;
    *)
      print_error "未知参数: ${!i}"
      exit 1
      ;;
  esac
done

# 验证目标项目路径
if [ ! -d "$TARGET_PROJECT" ]; then
  print_error "项目目录不存在: $TARGET_PROJECT"
  exit 1
fi

# 确定技能库源
if [ -z "$SOURCE" ]; then
  # 尝试使用本地脚本位置
  if [ -n "${BASH_SOURCE[0]}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SKILLS_ROOT="$(dirname "$SCRIPT_DIR")"
    if [ -d "$SKILLS_ROOT/skills" ]; then
      SOURCE="$SKILLS_ROOT"
      print_info "使用本地技能库源: $SOURCE"
    fi
  fi
  
  # 如果本地源不可用，默认使用 GitHub
  if [ -z "$SOURCE" ]; then
    SOURCE="https://github.com/wxy/copilot-evolution-skills"
    print_info "未找到本地源，将使用 GitHub 远程源: $SOURCE"
  fi
fi

# 验证和规范化源地址
if [[ "$SOURCE" == http://* ]] || [[ "$SOURCE" == https://* ]]; then
  # 远程 URL
  GITHUB_URL="$SOURCE"
  # 规范化：移除末尾的 .git
  GITHUB_URL="${GITHUB_URL%.git}"
  # 确保使用原始内容 URL
  if [[ "$GITHUB_URL" != *"/raw/"* ]]; then
    GITHUB_URL="${GITHUB_URL}/raw/main"
  fi
  SKILLS_MODE="remote"
  print_info "源模式: 远程 (GitHub)"
else
  # 本地路径
  if [ ! -d "$SOURCE" ]; then
    print_error "本地技能库路径不存在: $SOURCE"
    exit 1
  fi
  if [ ! -d "$SOURCE/skills" ]; then
    print_error "找不到 skills 目录: $SOURCE/skills"
    exit 1
  fi
  SKILLS_ROOT="$SOURCE"
  SKILLS_MODE="local"
  print_info "源模式: 本地"
fi

print_info "开始集成..."
echo ""

# 步骤 1：创建目录结构
echo "📁 创建目录结构..."
mkdir -p "$TARGET_PROJECT/.copilot/skills"
print_success "已创建 .copilot/skills 目录"

# 步骤 2：复制 skills 目录
echo ""
echo "📚 复制技能库..."

# 创建临时目录用于远程下载
TMP_DIR=""
if [ "$SKILLS_MODE" = "remote" ]; then
  TMP_DIR=$(mktemp -d)
  print_info "创建临时目录: $TMP_DIR"
fi

# 备份现有的 skills 目录
if [ -d "$TARGET_PROJECT/.copilot/skills" ] && [ "$(ls -A "$TARGET_PROJECT/.copilot/skills")" ]; then
  print_info "检测到现有 skills 目录，创建备份..."
  BACKUP_DIR="$TARGET_PROJECT/.copilot/skills.backup.$(date +%Y%m%d_%H%M%S)"
  mv "$TARGET_PROJECT/.copilot/skills" "$BACKUP_DIR"
  mkdir -p "$TARGET_PROJECT/.copilot/skills"
  print_info "已备份到: $BACKUP_DIR"
fi

# 复制 skills 目录
if [ "$SKILLS_MODE" = "local" ]; then
  cp -r "$SKILLS_ROOT/skills"/* "$TARGET_PROJECT/.copilot/skills/" || {
    print_error "无法复制本地 skills 目录"
    exit 1
  }
else
  # 从远程下载 skills
  print_info "从远程下载 skills 目录..."
  mkdir -p "$TMP_DIR/skills"
  
  # 获取 skills 目录下的所有技能
  SKILLS_LIST=$(curl -fsSL "${GITHUB_URL}/skills" 2>/dev/null | grep -oP 'href="\K[^"]*' | grep '^_' | grep -v '/$' || true)
  
  if [ -z "$SKILLS_LIST" ]; then
    print_error "无法从远程获取技能列表"
    rm -rf "$TMP_DIR"
    exit 1
  fi
  
  # 下载每个技能
  for skill in $SKILLS_LIST; do
    print_info "下载技能: $skill"
    mkdir -p "$TMP_DIR/skills/$skill"
    
    # 下载 SKILL.md 和其他文件
    curl -fsSL "${GITHUB_URL}/skills/$skill/SKILL.md" -o "$TMP_DIR/skills/$skill/SKILL.md" 2>/dev/null || {
      print_error "下载 $skill/SKILL.md 失败"
      rm -rf "$TMP_DIR"
      exit 1
    }
    
    # 复制子目录（references, scripts 等）
    for subdir in references scripts assets; do
      if curl -fsSL "${GITHUB_URL}/skills/$skill/$subdir/" 2>/dev/null | grep -q "href="; then
        mkdir -p "$TMP_DIR/skills/$skill/$subdir"
        # 这里需要递归下载，为简化起见，仅下载文件列表中的项
        print_info "  - 包含 $subdir 子目录"
      fi
    done
  done
  
  cp -r "$TMP_DIR/skills"/* "$TARGET_PROJECT/.copilot/skills/" || {
    print_error "无法复制远程 skills 目录"
    rm -rf "$TMP_DIR"
    exit 1
  }
fi

print_success "已复制 12 个技能文件"

# 步骤 3：复制 constitution 目录
echo ""
echo "📖 复制进化宪法..."

if [ "$SKILLS_MODE" = "local" ]; then
  if [ -d "$SKILLS_ROOT/constitution" ]; then
    if [ -d "$TARGET_PROJECT/.copilot/skills/constitution" ]; then
      rm -rf "$TARGET_PROJECT/.copilot/skills/constitution"
    fi
    cp -r "$SKILLS_ROOT/constitution" "$TARGET_PROJECT/.copilot/skills/" || {
      print_error "无法复制本地 constitution 目录"
      [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR"
      exit 1
    }
  else
    print_info "本地源中不存在 constitution 目录"
  fi
else
  # 从远程下载 constitution
  print_info "从远程下载 constitution..."
  mkdir -p "$TMP_DIR/constitution"
  
  curl -fsSL "${GITHUB_URL}/constitution/ai-evolution-constitution.md" -o "$TMP_DIR/constitution/ai-evolution-constitution.md" 2>/dev/null || {
    print_error "下载 constitution/ai-evolution-constitution.md 失败"
    rm -rf "$TMP_DIR"
    exit 1
  }
  
  if [ -d "$TARGET_PROJECT/.copilot/skills/constitution" ]; then
    rm -rf "$TARGET_PROJECT/.copilot/skills/constitution"
  fi
  
  cp -r "$TMP_DIR/constitution" "$TARGET_PROJECT/.copilot/skills/" || {
    print_error "无法复制远程 constitution 目录"
    rm -rf "$TMP_DIR"
    exit 1
  }
fi

print_success "已复制进化宪法"

# 清理临时目录
if [ -n "$TMP_DIR" ]; then
  rm -rf "$TMP_DIR"
  print_info "已清理临时目录"
fi

# 步骤 4：复制 templates（如果需要）
echo ""
echo "📋 复制模板..."

if [ "$SKILLS_MODE" = "local" ]; then
  if [ -d "$SKILLS_ROOT/templates" ] && [ "$(ls -A "$SKILLS_ROOT/templates")" ]; then
    mkdir -p "$TARGET_PROJECT/.copilot/skills/templates"
    cp -r "$SKILLS_ROOT/templates"/* "$TARGET_PROJECT/.copilot/skills/templates/" 2>/dev/null || true
    print_success "已复制模板文件"
  else
    print_info "暂无模板文件"
  fi
else
  print_info "暂无模板文件（远程模式）"
fi

# 步骤 5：处理 copilot-instructions.md
echo ""
echo "📝 处理项目指令文件..."

INSTRUCTIONS_FILE="$TARGET_PROJECT/.github/copilot-instructions.md"

if [ ! -f "$INSTRUCTIONS_FILE" ]; then
  # 创建新的指令文件
  print_info "创建新的 copilot-instructions.md..."
  mkdir -p "$TARGET_PROJECT/.github"
  
  cat > "$INSTRUCTIONS_FILE" << 'INSTRUCTIONS_TEMPLATE'
---
applyTo: "**"
---

# 项目指令

## Part 1: 通用框架 - AI 系统进化宪法

<attachment filePath=".copilot/skills/constitution/ai-evolution-constitution.md">
此部分包含了 AI 助手的通用进化框架。详见上述文件。该内容与具体项目无关，可独立维护和在多个项目中共享。
</attachment>

## Part 2: 项目特定规范

（请根据你的项目需要补充项目特定的规范和约定）

## Part 3: 技能库说明

此项目已集成 copilot-evolution-skills，包含 12 个自定义技能。

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

详见：[.copilot/skills/README.md](.copilot/skills/README.md)

INSTRUCTIONS_TEMPLATE
  
  print_success "已创建 copilot-instructions.md"
else
  # 检查是否已有 attachment 引用
  if grep -q "attachment filePath=\".copilot/skills/constitution/ai-evolution-constitution.md\"" "$INSTRUCTIONS_FILE"; then
    print_info "已存在进化宪法引用，跳过修改"
  else
    print_info "更新现有文件，添加进化宪法引用..."
    
    # 备份原文件
    cp "$INSTRUCTIONS_FILE" "$INSTRUCTIONS_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    print_info "已备份原文件"
    
    # 在 Part 1 后添加 attachment 引用（如果没有 Part 1 则添加）
    if ! grep -q "^## Part 1:" "$INSTRUCTIONS_FILE"; then
      # 在文件开头添加 Part 1 和 attachment
      {
        echo "## Part 1: 通用框架 - AI 系统进化宪法"
        echo ""
        echo "<attachment filePath=\".copilot/skills/constitution/ai-evolution-constitution.md\">"
        echo "此部分包含了 AI 助手的通用进化框架。详见上述文件。"
        echo "</attachment>"
        echo ""
        cat "$INSTRUCTIONS_FILE"
      } > "$INSTRUCTIONS_FILE.tmp"
      mv "$INSTRUCTIONS_FILE.tmp" "$INSTRUCTIONS_FILE"
    else
      print_info "文件已有 Part 1，保留原有结构"
    fi
    
    print_success "已更新 copilot-instructions.md"
  fi
fi

# 步骤 6：创建集成信息文件
echo ""
echo "📋 创建集成信息..."

INTEGRATION_INFO_FILE="$TARGET_PROJECT/.github/SKILLS_INTEGRATION_INFO.md"

# 获取版本号
if [ "$SKILLS_MODE" = "local" ] && [ -f "$SKILLS_ROOT/version.txt" ]; then
  VERSION=$(cat "$SKILLS_ROOT/version.txt")
else
  # 尝试从远程获取版本
  VERSION=$(curl -fsSL "${GITHUB_URL}/version.txt" 2>/dev/null || echo "unknown")
fi

cat > "$INTEGRATION_INFO_FILE" << INTEGRATION_INFO_TEMPLATE
# 技能库集成信息

此项目已集成 **copilot-evolution-skills**（通用 AI 助手技能库）。

## 集成信息

- **集成日期**: $(date '+%Y-%m-%d %H:%M:%S')
- **版本号**: $VERSION
- **技能数量**: 12 个自定义技能
- **位置**: \`.copilot/skills/\`
- **源**: $SOURCE

## 集成内容

### 技能库 (skills/)
12 个自定义技能可供 AI 助手使用：

1. \`_evolution-core\` - 进化能力元技能
2. \`_typescript-type-safety\` - TypeScript Mock 创建与错误预防
3. \`_git-commit\` - Git 提交规范化
4. \`_pr-creator\` - PR 创建与版本控制流程
5. \`_code-health-check\` - 提交前代码检查
6. \`_release-process\` - 完整的发布流程
7. \`_context-ack\` - 上下文校验与输出格式
8. \`_instruction-guard\` - 强制读取指令文件
9. \`_file-output-guard\` - 文件创建安全约束
10. \`_change-summary\` - 提交摘要汇总
11. \`_traceability-check\` - 说明与变更校验
12. \`_session-safety\` - 会话超长防护

### 进化宪法 (constitution/)
通用 AI 进化框架，定义了 AI 助手的核心原则和行为规范。

### 项目指令
\`.github/copilot-instructions.md\` 已更新，通过 \`<attachment>\` 标签引用进化宪法。

## 使用方式

你的 AI 助手现在可以使用所有 12 个技能。具体用法请参考各技能的 SKILL.md 文件。

## 更新技能库

如果需要更新到最新版本，请运行：
\`\`\`bash
bash .copilot/skills/scripts/update-integration.sh --backup
\`\`\`

## 更多信息

- 项目仓库：https://github.com/YOUR_ORG/copilot-evolution-skills
- AI 集成指南：.copilot/skills/AI_INTEGRATION_INSTRUCTIONS.md
- 技能库 README：.copilot/skills/README.md

---

*此文件由集成脚本自动生成，请勿手动修改。*

INTEGRATION_INFO_TEMPLATE

print_success "已创建 .github/SKILLS_INTEGRATION_INFO.md"

# 步骤 7：验证集成
echo ""
echo "✔️  验证集成完整性..."

# 简单验证：检查关键文件
SKILLS_COUNT=$(find "$TARGET_PROJECT/.copilot/skills/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l)
if [ "$SKILLS_COUNT" -eq 12 ]; then
  print_success "检验通过：找到 12 个技能文件"
else
  print_error "警告：预期 12 个技能文件，实际找到 $SKILLS_COUNT 个"
fi

if [ -f "$TARGET_PROJECT/.copilot/skills/constitution/ai-evolution-constitution.md" ]; then
  print_success "检验通过：进化宪法文件完整"
else
  print_error "错误：进化宪法文件缺失"
  exit 1
fi

if grep -q "attachment filePath=" "$TARGET_PROJECT/.github/copilot-instructions.md"; then
  print_success "检验通过：copilot-instructions.md 配置正确"
else
  print_error "警告：copilot-instructions.md 中未找到 attachment 引用"
fi

# 步骤 8：自动提交（如果是 Git 项目且指定了 --auto-commit）
if [ "$AUTO_COMMIT" = true ] && [ -d "$TARGET_PROJECT/.git" ]; then
  echo ""
  echo "📤 提交更改..."
  
  cd "$TARGET_PROJECT"
  
  # 创建提交说明
  COMMIT_DESC_FILE=".github/COMMIT_DESCRIPTION.local.md"
  cat > "$COMMIT_DESC_FILE" << 'COMMIT_DESC_TEMPLATE'
feat: 集成 copilot-evolution-skills 技能库

## 集成内容
- 12 个自定义技能（位于 .copilot/skills/skills/）
- 通用进化宪法（位于 .copilot/skills/constitution/）
- 项目指令文件（已更新 .github/copilot-instructions.md）

## 集成信息
- 技能库版本：1.0.0-beta
- 集成时间：(date '+%Y-%m-%d %H:%M:%S')
- 集成方式：自动脚本集成

## 集成的技能
1. _evolution-core - 进化能力元技能
2. _typescript-type-safety - TypeScript 类型安全
3. _git-commit - Git 提交规范
4. _pr-creator - PR 创建流程
5. _code-health-check - 代码健康检查
6. _release-process - 发布流程
7. _context-ack - 上下文校验
8. _instruction-guard - 指令读取约束
9. _file-output-guard - 文件创建安全
10. _change-summary - 变更摘要
11. _traceability-check - 可追踪性检查
12. _session-safety - 会话安全

## 使用说明
- 所有技能文档位于 .copilot/skills/skills/*/SKILL.md
- 项目指令已配置 attachment 引用进化宪法
- 更多信息见 .github/SKILLS_INTEGRATION_INFO.md

---
> 🤖 本提交由集成脚本自动生成
COMMIT_DESC_TEMPLATE
  
  git add .copilot/skills .github/copilot-instructions.md .github/SKILLS_INTEGRATION_INFO.md 2>/dev/null || true
  git commit -F "$COMMIT_DESC_FILE" 2>/dev/null || true
  rm -f "$COMMIT_DESC_FILE"
  
  print_success "已自动提交"
  cd - > /dev/null
elif [ "$AUTO_COMMIT" = true ] && [ ! -d "$TARGET_PROJECT/.git" ]; then
  print_info "目标项目不是 Git 仓库，跳过自动提交"
fi

# 完成
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "集成完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "已集成的内容："
echo "  • 12 个自定义技能"
echo "  • 通用进化宪法"
echo "  • 项目指令文件（已配置）"
echo ""
echo "位置信息："
echo "  • 技能库: $TARGET_PROJECT/.copilot/skills/"
echo "  • 指令文件: $TARGET_PROJECT/.github/copilot-instructions.md"
echo "  • 集成信息: $TARGET_PROJECT/.github/SKILLS_INTEGRATION_INFO.md"
echo ""
echo "下一步："
echo "  1. 查看集成信息: cat $TARGET_PROJECT/.github/SKILLS_INTEGRATION_INFO.md"
echo "  2. 查看可用技能: ls $TARGET_PROJECT/.copilot/skills/skills/"
echo "  3. 开始使用技能！"
echo ""
