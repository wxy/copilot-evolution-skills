# copilot-evolution-skills

> 通用 AI 助手技能库 + 进化宪法框架

---

## 🚀 集成方式（AI 执行）

**用户说：**
```
请集成 https://github.com/wxy/copilot-evolution-skills 下的技能到本项目
```

**AI 执行：**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/setup.sh)
```

**脚本自动完成：**
- ✅ 添加 Git submodule 到 `.copilot/skills/`
- ✅ 配置稀疏检出（仅下载 `skills/` 和 `constitution/`）
- ✅ 更新 `.github/copilot-instructions.md`（添加进化宪法引用）
- ✅ 自动提交变更

**验证：**
```bash
git submodule status
ls -la .copilot/skills/
```

**完成：**
```bash
git push
```

---

## 📋 包含内容

### 技能库 (skills/)
可复用的工程技能，覆盖：
- Git 工作流（提交规范、PR 创建）
- 代码质量（类型安全、健康检查）
- 发布流程（完整的版本管理）
- 进化能力（识别模式、沉淀技能）

### 进化宪法 (constitution/)
AI 系统的通用进化框架，独立于具体项目。

---

## 🔄 更新技能

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/update.sh)
```

脚本会自动处理冲突（合并或衍合）。

---

## 🤝 贡献技能

如果你的项目产生了新技能或改进：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wxy/copilot-evolution-skills/main/scripts/contribute.sh)
```

脚本会创建 PR 到本仓库。

---

## 📝 许可证

MIT License

---

## 🙏 致谢

源于 [SilentFeed](https://github.com/wxy/SilentFeed)
