#!/usr/bin/env bash
# Ticket 04: pi 包格式验证
# 验证 package.json / LICENSE / README 符合 pi 包发布要求
set -eo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

ok()   { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

# ============================================================
# Section 1: package.json
# ============================================================
echo ""
echo "=== Seam 1: package.json ==="

if [ ! -f "$ROOT/package.json" ]; then
  fail "package.json 不存在"
else
  ok "package.json 存在"

  # 1a: JSON 语法有效
  if python3 -m json.tool "$ROOT/package.json" >/dev/null 2>&1; then
    ok "package.json JSON 语法有效"
  else
    fail "package.json JSON 语法无效"
  fi

  # 用 python3 提取 JSON 字段（因系统无 jq）
  PYTHON_GET="python3 -c"

  # 1b: name 字段
  NAME=$($PYTHON_GET "import json; print(json.load(open('$ROOT/package.json')).get('name',''))" 2>/dev/null || echo "")
  if [ "$NAME" = "liuyao-skill" ]; then
    ok "name 字段 = liuyao-skill"
  else
    fail "name 字段应为 liuyao-skill，实际为: $NAME"
  fi

  # 1c: version 字段
  VER=$($PYTHON_GET "import json; print(json.load(open('$ROOT/package.json')).get('version',''))" 2>/dev/null || echo "")
  if echo "$VER" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    ok "version 字段 = $VER"
  else
    fail "version 字段缺失或格式无效: $VER"
  fi

  # 1d: keywords 包含 pi-package
  HAS_PI_KEYWORD=$($PYTHON_GET "import json; d=json.load(open('$ROOT/package.json')); kw=d.get('keywords',[]); print('yes' if 'pi-package' in kw else 'no')" 2>/dev/null || echo "no")
  if [ "$HAS_PI_KEYWORD" = "yes" ]; then
    ok "keywords 包含 pi-package"
  else
    fail "keywords 缺少 pi-package"
  fi

  # 1e: license 字段
  LIC=$($PYTHON_GET "import json; print(json.load(open('$ROOT/package.json')).get('license',''))" 2>/dev/null || echo "")
  if [ "$LIC" = "MIT" ]; then
    ok "license 字段 = MIT"
  else
    fail "license 字段应为 MIT，实际为: $LIC"
  fi

  # 1f: pi.skills 数组包含 ./
  HAS_SKILLS=$($PYTHON_GET "import json; d=json.load(open('$ROOT/package.json')); pi=d.get('pi',{}); skills=pi.get('skills',[]); print('yes' if './' in skills else 'no')" 2>/dev/null || echo "no")
  if [ "$HAS_SKILLS" = "yes" ]; then
    ok "pi.skills 包含 ./"
  else
    fail "pi.skills 应包含 ./"
  fi
fi

# ============================================================
# Section 2: LICENSE
# ============================================================
echo ""
echo "=== Seam 2: LICENSE ==="

if [ ! -f "$ROOT/LICENSE" ]; then
  fail "LICENSE 文件不存在"
else
  ok "LICENSE 文件存在"
  if grep -q "MIT License" "$ROOT/LICENSE"; then
    ok "LICENSE 包含 MIT License"
  else
    fail "LICENSE 不包含 MIT License 标识"
  fi
  if grep -q "Copyright (c)" "$ROOT/LICENSE"; then
    ok "LICENSE 包含 Copyright"
  else
    fail "LICENSE 不包含 Copyright"
  fi
  if grep -iq "Permission is hereby granted" "$ROOT/LICENSE"; then
    ok "LICENSE 包含标准 MIT 授权文本"
  else
    fail "LICENSE 缺少标准 MIT 授权文本"
  fi
fi

# ============================================================
# Section 3: README 内容完整性
# ============================================================
echo ""
echo "=== Seam 3: README ==="

if [ ! -f "$ROOT/README.md" ]; then
  fail "README.md 不存在"
else
  ok "README.md 存在"

  # 3a: 安装说明
  if grep -q "pi install" "$ROOT/README.md"; then
    ok "README 包含 pi install 安装说明"
  else
    fail "README 缺少 pi install 安装说明"
  fi

  # 3b: 安装方式（git 路径）
  if grep -q "github.com" "$ROOT/README.md"; then
    ok "README 包含 GitHub 安装路径"
  else
    fail "README 缺少 GitHub 安装路径"
  fi

  # 3c: 快速开始
  if grep -q -i "快速开始\|quick start\|使用方法" "$ROOT/README.md"; then
    ok "README 包含快速开始/使用方法"
  else
    fail "README 缺少快速开始/使用说明"
  fi

  # 3d: 文件结构
  if grep -q "SKILL.md\|文件结构" "$ROOT/README.md"; then
    ok "README 包含文件结构说明"
  else
    fail "README 缺少文件结构说明"
  fi
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "===================="
echo "结果: $PASS 通过, $FAIL 失败"
echo "===================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
