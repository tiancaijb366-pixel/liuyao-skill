#!/usr/bin/env bash
# 验证 Ticket 02：SKILL.md 附录 6 张复杂规则表完整性
# 用法：bash scripts/verify-appendix-tables.sh
set -eo pipefail

SKILL="../SKILL.md"
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

echo "═══ 附录规则表验证 ═══"
echo

# ─── Table 6: 浑天甲子（纳甲）表 ───
echo "▸ 浑天甲子（纳甲）表 ① 易冒·纳甲章第四"
check "乾卦纳甲" "乾.*子水.*寅木.*辰土"
check "坤卦纳甲" "坤.*未土.*巳火.*卯木"
check "震卦纳甲" "震.*子水.*寅木.*辰土"
check "坎卦纳甲" "坎.*寅木.*辰土.*午火"
check "艮卦纳甲" "艮.*辰土.*午火.*申金"
check "巽卦纳甲" "巽.*丑土.*亥水.*酉金"
check "离卦纳甲" "离.*卯木.*丑土.*亥水"
check "兑卦纳甲" "兑.*巳火.*卯木.*丑土"
check "说明备注" "长子袭父"
check "来源标注" "① 易冒·纳甲章第四"
echo

# ─── Table 7: 八宫六十四卦卦序 ───
echo "▸ 八宫六十四卦卦序 ① 易冒·成卦章第三"
check "乾宫八纯" "䷀"
check "乾宫一世" "䷫"
check "乾宫游魂" "䷢"
check "乾宫归魂" "䷍"
check "坎宫八纯" "䷜"
check "坎宫游魂" "䷣"
check "坎宫归魂" "䷆"
check "艮宫八纯" "䷳"
check "艮宫归魂" "䷴"
check "震宫八纯" "䷲"
check "震宫游魂" "䷛"
check "震宫归魂" "䷐"
check "巽宫八纯" "䷸"
check "巽宫游魂" "䷚"
check "巽宫归魂" "䷑"
check "离宫八纯" "䷝"
check "离宫游魂" "䷅"
check "离宫归魂" "䷌"
check "坤宫八纯" "䷁"
check "坤宫游魂" "䷄"
check "坤宫归魂" "䷇"
check "兑宫八纯" "䷹"
check "兑宫游魂" "䷽"
check "兑宫归魂" "䷵"
check "来源标注" "① 易冒·成卦章第三"
echo

# ─── Table 8: 五行旺相休囚死 ───
echo "▸ 五行旺相休囚死 ② 增删卜易·四时旺相章"
check "春木旺" "春.*寅卯月.*木"
check "夏火旺" "夏.*巳午月.*火"
check "秋金旺" "秋.*申酉月.*金"
check "冬水旺" "冬.*亥子月.*水"
check "四季土旺" "四季.*辰戌丑未月.*土"
check "口诀" "当令者旺"
check "释义" "木旺于春，则火相"
check "来源标注" "② 增删卜易·四时旺相章"
echo

# ─── Table 9: 生旺墓绝十二宫 ───
echo "▸ 生旺墓绝十二宫 ① 易冒·墓绝章第十八"
check "金长生十二宫标题" "金长生十二宫"
check "木长生十二宫标题" "木长生十二宫"
check "火长生十二宫标题" "火长生十二宫"
check "水土长生十二宫标题" "水土长生十二宫.*水土同宫"
check "金十二宫数据" "巳.*午.*未.*申.*酉.*戌"
check "木十二宫数据" "亥.*子.*丑.*寅.*卯.*辰"
check "火十二宫数据" "寅.*卯.*辰.*巳.*午.*未"
check "水土十二宫数据" "申.*酉.*戌.*亥.*子.*丑"
check "备注两墓二绝" "两墓二绝一生旺"
check "来源标注" "① 易冒·墓绝章第十八"
echo

# ─── Table 10: 地支冲合刑害 ───
echo "▸ 地支冲合刑害 ① 易冒·合冲章第九/刑害章"
check "六冲子午" "子午冲\|子↔午"
check "六冲寅申" "寅申冲\|寅↔申"
check "六合子丑" "子丑合\|子↔丑"
check "六合寅亥" "寅亥合\|寅↔亥"
check "三刑寅巳申" "寅巳申三刑\|无恩之刑"
check "三刑丑戌未" "丑戌未三刑\|恃势之刑"
check "子卯刑" "子卯刑\|无礼之刑"
check "自刑" "辰.*午.*酉.*亥.*自刑"
check "六害子未" "子未害\|子↔未"
check "六害申亥" "申亥害\|申↔亥"
check "刑开墓说明" "刑可开墓"
check "来源标注" "① 易冒·合冲章第九\s*/\s*刑害章"
echo

# ─── Table 11: 旬空表 ───
echo "▸ 旬空表 ① 易冒·旬空章第二十六"
check "甲子旬戌亥空" "甲子.*戌.*亥"
check "甲戌旬申酉空" "甲戌.*申.*酉"
check "甲申旬午未空" "甲申.*午.*未"
check "甲午旬辰巳空" "甲午.*辰.*巳"
check "甲辰旬寅卯空" "甲辰.*寅.*卯"
check "甲寅旬子丑空" "甲寅.*子.*丑"
check "旬空要点说明" "用神旬空.*吉凶未定"
check "来源标注" "① 易冒·旬空章第二十六"
echo

# ─── Summary ───
echo "═══ 结果: $PASS 通过 / $FAIL 失败 / 共 $TOTAL 项 ═══"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
