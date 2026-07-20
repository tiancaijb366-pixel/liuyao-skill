# 04 — pi 包 + GitHub 发布

**What to build:** 添加 pi 包支持（package.json），创建 GitHub 仓库，添加 MIT License，完善 README，使 skill 可通过 `pi install` 安装。

**Blocked by:** 02 — 规则表附录完整嵌入（发布前需有完成版 SKILL.md）

**Status:** ready-for-agent

## 具体内容

### 1. package.json

```json
{
  "name": "liuyao-divination",
  "version": "1.0.0",
  "keywords": ["pi-package", "liuyao", "divination"],
  "pi": {
    "skills": ["./"]
  }
}
```

### 2. GitHub 仓库

- 创建 GitHub 仓库（名称待定，建议 `liuyao-skill`）
- `git init` → `git remote add origin ...` → push

### 3. MIT LICENSE

标准 MIT License 文件。

### 4. README 完善

- 安装方式：`pi install git:...`
- 使用方法（快速开始）
- 多 agent 使用说明（重新整理现有 README.md）

## 验收标准

- [ ] package.json 已添加，pi install 可安装
- [ ] GitHub 仓库已创建并推送
- [ ] MIT LICENSE 文件已添加
- [ ] README 已更新（含安装说明）
- [ ] `docs/agents/issue-tracker.md` 中的 GitHub 仓库配置可实际使用
