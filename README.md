# 六爻占卜解读 Skill

基于《增删卜易》《易冒》的六爻结构化解读 Skill，支持多 Agent 使用。

## 支持的 Agent

| Agent | 使用方法 |
|-------|---------|
| **pi / Workbuddy** | `pi install git:github.com/yourname/liuyao-skill` 或直接复制到 `.pi/agent/skills/` |
| **Claude Code** | 将 `SKILL.md` 内容复制到项目根目录的 `CLAUDE.md`，或使用 `/skill:` 命令 |
| **Codex CLI** | 将 `SKILL.md` 内容复制到 `CODEX.md` |
| **Cursor** | 手动引用 `SKILL.md` 内容到 `.cursorrules` |
| **其他 Agent** | 复制 `SKILL.md` 内容作为 system prompt 的一部分 |

## 文件结构

```
liuyao-skill/
├── SKILL.md           # 主 Skill 文件（解读流程）
├── CONTEXT.md          # 术语表（agent 上下文）
├── README.md           # 本文件
└── references/
    ├── 增删卜易.md     # 参考书：《增删卜易》
    └── 易冒.md         # 参考书：《易冒》
```

## 使用方法

1. 准备六爻卦象数据（排盘工具输出）
2. 调用 skill（各 agent 方式不同）
3. 粘贴卦象数据
4. 按 Phase 1→4 逐步解读

## 数据来源

- 《增删卜易》（清·野鹤老人著 / 李文辉增删）— 公版古籍
- 《易冒》（清·程良玉著）— 公版古籍
