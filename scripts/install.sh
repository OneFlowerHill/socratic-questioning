#!/usr/bin/env bash
# install.sh — deep-discussion 双端 symlink 安装/卸载（幂等）
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="deep-discussion"
CLAUDE_LINK="$HOME/.claude/skills/$NAME"
HERMES_LINK="$HOME/.hermes/skills/software-development/$NAME"

# 内容完整性预检查（CR-005）：建链前验证源目录含改名后技能
verify_source() {
  local skill="$SRC/SKILL.md"
  [ -f "$skill" ] || { echo "源缺 SKILL.md: $skill（内容未完成改名？）" >&2; exit 1; }
  local got; got="$(awk -F': ' '/^name:/{print $2; exit}' "$skill")"
  [ "$got" = "$NAME" ] || {
    echo "SKILL.md name='$got' 与脚本 NAME='$NAME' 不一致（内容未完成改名？）" >&2
    exit 1
  }
}

link() {  # link <target> <link_path>
  local target="$1" link_path="$2"
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo "已存在且指向同源，跳过: $link_path"
    return 0
  fi
  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    echo "目标已存在且非同源 symlink，不覆盖: $link_path" >&2
    return 1
  fi
  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path" && echo "已安装: $link_path -> $target"
}

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$CLAUDE_LINK" "$HERMES_LINK"
  echo "已卸载: $CLAUDE_LINK, $HERMES_LINK"
  exit 0
fi

verify_source

# 两次 link 尽量完成，部分失败时提示恢复（CR-004）
claude_ok=0; hermes_ok=0
link "$SRC" "$CLAUDE_LINK" && claude_ok=1 || true
link "$SRC" "$HERMES_LINK" && hermes_ok=1 || true

if [ "$claude_ok$hermes_ok" != "11" ]; then
  echo "部分安装：Claude=$([ $claude_ok -eq 1 ] && echo 已装 || echo 未装)、Hermes=$([ $hermes_ok -eq 1 ] && echo 已装 || echo 未装)。" >&2
  echo "可执行 'bash scripts/install.sh --uninstall' 清理后重试。" >&2
  exit 1
fi

echo "双端安装完成: $NAME"
