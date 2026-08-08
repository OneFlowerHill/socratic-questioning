#!/usr/bin/env bash
# check-acceptance-anchors.sh — 校验 acceptance.md 内 "第 NN 行 #行首文本" 锚点
# 与 SKILL.md 实际行行首是否匹配。不依赖 "+5 行" 假设，以 SKILL.md 实际行为真值。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL="$SRC/SKILL.md"
ACCEPT="$SRC/docs/superpowers/plans/2026-07-29-socratic-questioning-acceptance.md"

for f in "$SKILL" "$ACCEPT"; do
  [ -f "$f" ] || { echo "缺文件: $f" >&2; exit 2; }
done

SKILL_LINES=()
while IFS= read -r line; do
  SKILL_LINES+=("$line")
done < "$SKILL"
total=${#SKILL_LINES[@]}

diffs=0
checked=0

# 提取所有 "第 N 行 #锚点" 模式，转为 "N|锚点"
while IFS= read -r pair; do
  [ -z "$pair" ] && continue
  ln="${pair%%|*}"
  anchor="${pair#*|}"
  [ -z "$anchor" ] && continue
  checked=$((checked+1))

  if [ "$ln" -lt 1 ] || [ "$ln" -gt "$total" ]; then
    echo "FAIL: 行号 $ln 超出 SKILL.md 范围(1..$total)  锚点=#$anchor"
    diffs=$((diffs+1))
    continue
  fi

  actual="${SKILL_LINES[$((ln-1))]}"
  # 去行首空白
  actual_trim="${actual#"${actual%%[![:space:]]*}"}"

  if [[ "$actual_trim" == "$anchor"* ]]; then
    : # 匹配
  else
    echo "FAIL: 第 $ln 行 锚点=#$anchor"
    echo "  预期(锚点前缀): $anchor"
    echo "  实际(行首30字符): ${actual_trim:0:30}"
    diffs=$((diffs+1))
  fi
done < <(grep -oE '第[[:space:]]*[0-9]+[[:space:]]*行[[:space:]]*#[^ ，)。、【】]*' "$ACCEPT" \
         | sed -E 's/第[[:space:]]*([0-9]+)[[:space:]]*行[[:space:]]*#/\1|/')

echo ""
echo "共检查 $checked 个锚点，$diffs 处不匹配"
if [ "$diffs" -eq 0 ]; then
  echo "PASS: 全部锚点匹配 SKILL.md 实际行"
  exit 0
else
  echo "FAIL: 见上方差异清单。据清单逐条修正 acceptance.md 行号后重跑。"
  exit 1
fi
