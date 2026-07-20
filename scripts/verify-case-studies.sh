#!/usr/bin/env bash
# Ticket 03: 卦例测试套件 — 验证测例数据完整性与 SKILL.md 覆盖度
# 用法：bash scripts/verify-case-studies.sh
set -eo pipefail

SCRIPT_DIR="$(dirname "$0")"
CASE_DIR="$SCRIPT_DIR/case-studies"
SKILL="$SCRIPT_DIR/../SKILL.md"
PASS=0
FAIL=0
TOTAL=0

ok()   { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

check() {
  TOTAL=$((TOTAL+1))
  local label="$1" pattern="$2"
  if grep -q "$pattern" "$SKILL"; then
    ok "$label"
  else
    fail "$label"
  fi
}

check_json_field() {
  TOTAL=$((TOTAL+1))
  local file="$1" field="$2"
  if python3 -c "import json; d=json.load(open('$file')); print(d.get('$field') is not None)" 2>/dev/null | grep -q True; then
    ok "$file 字段: $field"
  else
    fail "$file 缺少字段: $field"
  fi
}

echo "═══ 卦例测试套件验证 ═══"
echo

# ─── 第一步：校验测例目录存在 ───
echo "▸ 测例目录结构"
if [ -d "$CASE_DIR" ]; then
  ok "测例目录存在: $CASE_DIR"
else
  fail "测例目录不存在: $CASE_DIR"
fi
echo

# ─── 第二步：校验 JSON 文件数量和质量 ───
echo "▸ 测例 JSON 文件"

# 使用 nullglob 防止空匹配时返回 glob 字面值
shopt -s nullglob
CASE_FILES=("$CASE_DIR"/*.json)
CASE_COUNT=${#CASE_FILES[@]}

if [ "$CASE_COUNT" -ge 35 ]; then
  ok "测例数量: $CASE_COUNT 个（达标 ✅）"
elif [ "$CASE_COUNT" -ge 25 ]; then
  ok "测例数量: $CASE_COUNT 个（接近目标 35+）"
elif [ "$CASE_COUNT" -ge 15 ]; then
  ok "测例数量: $CASE_COUNT 个（首批 PoC，后续扩展）"
else
  fail "测例数量不足: $CASE_COUNT 个（需 ≥15）"
fi

# 校验每个 JSON 文件
for f in "${CASE_FILES[@]}"; do
  [ ! -f "$f" ] && continue
  BASENAME=$(basename "$f")

  # Validate JSON syntax
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
    ok "$BASENAME JSON 格式有效"
  else
    fail "$BASENAME JSON 格式无效"
    continue
  fi

  # Check required fields
  check_json_field "$f" "id"
  check_json_field "$f" "来源"
  check_json_field "$f" "问题"
  check_json_field "$f" "日月建"
  check_json_field "$f" "本卦"
  check_json_field "$f" "变卦"
  check_json_field "$f" "断语吉凶"
  check_json_field "$f" "验证点"
  check_json_field "$f" "应期"
  check_json_field "$f" "时间"
  # Check unified field names: all case studies use 断语/用神 (regardless of source)
  TOTAL=$((TOTAL+1))
  BASENAME=$(basename "$f")
  if python3 -c "import json; d=json.load(open('$f')); print(d.get('断语') is not None)" 2>/dev/null | grep -q True; then
    ok "$BASENAME 字段: 断语"
  else
    fail "$BASENAME 缺少字段: 断语"
  fi
  TOTAL=$((TOTAL+1))
  if python3 -c "import json; d=json.load(open('$f')); print(d.get('用神') is not None)" 2>/dev/null | grep -q True; then
    ok "$BASENAME 字段: 用神"
  else
    fail "$BASENAME 缺少字段: 用神"
  fi
  if [ "$(python3 -c "import json; print(json.load(open('$f')).get('变卦',''))" 2>/dev/null)" != "无（静卦）" ]; then
    check_json_field "$f" "世应"
    check_json_field "$f" "动爻"
  fi

  # Verify ID uniqueness (within this file - it's a single object per file)
  ID=$(python3 -c "import json; print(json.load(open('$f'))['id'])" 2>/dev/null)
  # Check ID prefix
  case "$ID" in
    zs-*) ok "$BASENAME ID前缀 zs- (增删卜易)" ;;
    ym-*) ok "$BASENAME ID前缀 ym- (易冒)" ;;
    gs-*) ok "$BASENAME ID前缀 gs- (古筮真诠)" ;;
    *)    fail "$BASENAME ID前缀不规范: $ID" ;;
  esac
done
echo

# ─── 第三步：验证 SKILL.md 对测例关键概念的覆盖 ───
echo "▸ SKILL.md 关键概念覆盖检查"

# 收集所有验证点中的关键词，去重检查
KEY_CONCEPTS=$(for f in "${CASE_FILES[@]}"; do
  [ ! -f "$f" ] && continue
  python3 -c "import json; print('\n'.join(json.load(open('$f'))['验证点']))" 2>/dev/null
done | sort -u)

CONCEPT_COUNT=0
CONCEPT_PASS=0
for concept in $KEY_CONCEPTS; do
  CONCEPT_COUNT=$((CONCEPT_COUNT+1))
  # Map concept to SKILL.md search term
  case "$concept" in
    "用神选取")
      if grep -qi "用神" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "六冲断法")
      if grep -qi "六冲" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "贪合忘克")
      if grep -qi "贪合" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "应期判断")
      if grep -qi "应期" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "暗动")
      if grep -qi "暗动" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "用神无根")
      if grep -qi "无根" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "月破")
      if grep -qi "月破" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "元神入墓")
      if grep -qi "墓" "$SKILL" && grep -qi "元神" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "回头克")
      if grep -qi "回头克" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "回头生")
      if grep -qi "回头生" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "日月克")
      if grep -qi "日月" "$SKILL" && grep -qi "克" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "父母持世")
      if grep -qi "持世" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "伏神")
      if grep -qi "伏神\|飞伏" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "再占验证")
      if grep -qi "再占\|代占" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "月墓")
      if grep -qi "墓" "$SKILL" && grep -qi "月" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "冲合")
      if grep -qi "冲.*合\|六冲\|六合" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "静卦")
      if grep -qi "静卦\|安静" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "旺相休囚")
      if grep -qi "旺相.*休囚\|旺相休囚" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "日辰")
      if grep -qi "日辰\|日建" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "生克")
      if grep -qi "生克\|相生\|相克" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "日克")
      if grep -qi "日辰.*克\|日克\|克.*日" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "元神无力")
      if grep -qi "元神.*无力\|元神.*不生" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "化吉")
      if grep -qi "化吉\|化.*为吉\|变吉" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "化绝")
      if grep -qi "化绝\|化.*绝\|变绝" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "子孙持世"|"官鬼持世"|"兄弟持世")
      if grep -qi "持世" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "简易自占法")
      if grep -qi "自占法\|简易自占" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "官鬼生用神")
      if grep -qi "官鬼.*生\|用神.*生" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "用神生世")
      if grep -qi "用神生世\|用神.*生世" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "事外解读")
      if grep -qi "事外\|兼象" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "化解策略")
      if grep -qi "化解" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "反吟")
      if grep -qi "反吟" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "化进神")
      if grep -qi "化进\|进神" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "心态卦")
      if grep -qi "心态卦" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "旬空")
      if grep -qi "旬空" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "月建")
      if grep -qi "月建" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "独发")
      if grep -qi "独发" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    "入墓")
      if grep -qi "入墓\|墓" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
    *)
      # Generic check: try searching the term directly
      if grep -qi "$concept" "$SKILL"; then
        CONCEPT_PASS=$((CONCEPT_PASS+1))
      fi ;;
  esac
done

TOTAL=$((TOTAL+1))
if [ "$CONCEPT_COUNT" -gt 0 ]; then
  RATE=$((CONCEPT_PASS * 100 / CONCEPT_COUNT))
  if [ "$RATE" -ge 70 ]; then
    ok "关键概念覆盖: $CONCEPT_PASS/$CONCEPT_COUNT ($RATE% ≥ 70%)"
  else
    fail "关键概念覆盖: $CONCEPT_PASS/$CONCEPT_COUNT ($RATE% < 70%)"
  fi
else
  ok "关键概念覆盖: 无验证点可检查（首批测例可能暂无验证点）"
fi
echo

# ─── 第四步：按来源统计 ───
echo "▸ 按来源统计"
ZS_COUNT=0
YM_COUNT=0
GS_COUNT=0
for f in "${CASE_FILES[@]}"; do
  [ ! -f "$f" ] && continue
  SRC=$(python3 -c "import json; print(json.load(open('$f'))['来源'])" 2>/dev/null)
  case "$SRC" in
    增删*) ZS_COUNT=$((ZS_COUNT+1)) ;;
    易冒*) YM_COUNT=$((YM_COUNT+1)) ;;
    古筮*) GS_COUNT=$((GS_COUNT+1)) ;;
  esac
done
TOTAL=$((TOTAL+1))
[ "$ZS_COUNT" -ge 1 ] && ok "增删卜易: $ZS_COUNT 例" || fail "增删卜易: 0 例"
TOTAL=$((TOTAL+1))
[ "$YM_COUNT" -ge 1 ] && ok "易冒: $YM_COUNT 例" || fail "易冒: 0 例"
TOTAL=$((TOTAL+1))
[ "$GS_COUNT" -ge 1 ] && ok "古筮真诠: $GS_COUNT 例" || fail "古筮真诠: 0 例"
echo

# ─── 第五步：验证测例中引用的卦名在 SKILL.md 中有对应规则 ───
echo "▸ 卦名识别检查"
for f in "${CASE_FILES[@]}"; do
  [ ! -f "$f" ] && continue
  BASENAME=$(basename "$f")
  BEN_GUA=$(python3 -c "import json; print(json.load(open('$f'))['本卦'])" 2>/dev/null)
  BIAN_GUA=$(python3 -c "import json; print(json.load(open('$f'))['变卦'])" 2>/dev/null)

  # Check that the hexagram names appear in SKILL.md appendix
  TOTAL=$((TOTAL+1))
  if [ -n "$BEN_GUA" ] && [ "$BEN_GUA" != "null" ]; then
    if grep -q "$BEN_GUA" "$SKILL"; then
      ok "$BASENAME 本卦 '$BEN_GUA' 在 SKILL.md 中有对应"
    else
      fail "$BASENAME 本卦 '$BEN_GUA' 在 SKILL.md 中未找到"
    fi
  fi

  TOTAL=$((TOTAL+1))
  if [ -n "$BIAN_GUA" ] && [ "$BIAN_GUA" != "null" ] && [ "$BIAN_GUA" != "无" ] && [[ "$BIAN_GUA" != *静卦* ]]; then
    if grep -q "$BIAN_GUA" "$SKILL"; then
      ok "$BASENAME 变卦 '$BIAN_GUA' 在 SKILL.md 中有对应"
    else
      fail "$BASENAME 变卦 '$BIAN_GUA' 在 SKILL.md 中未找到"
    fi
  fi
done
echo

# ─── Summary ───
echo "═══ 结果: $PASS 通过 / $FAIL 失败 / 共 $TOTAL 项 ═══"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
