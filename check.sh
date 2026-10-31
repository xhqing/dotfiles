#!/usr/bin/env bash
# 检查本机配置是否仍由本仓库托管：
#   1. mappings.conf 里每一条是不是指向仓库的软链（被原子写替换成普通文件时会掉链）
#   2. UserDefaults 快照是否与当前值有差异（差异只提示，不自动改）
#   3. 仓库本身是否有未提交改动
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAP="$REPO/mappings.conf"
fail=0

check_link() {
  local target="$1"
  local expected="$REPO/$2"

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    echo "❌ $target 不存在"
    fail=1
    return
  fi

  if [ ! -L "$target" ]; then
    echo "❌ $target 不是软链（可能被某个程序原子写替换了）——跑 ./install.sh 修好"
    fail=1
    return
  fi

  local actual
  actual="$(readlink "$target")"
  if [ "$actual" != "$expected" ]; then
    echo "❌ $target 指向 $actual，期望 $expected"
    fail=1
    return
  fi

  echo "✅ $target -> $expected"
}

echo "== 软链 =="
while IFS=$'\t' read -r src dst mode note; do
  case "$src" in
    ''|'#'*) continue ;;
  esac
  dst="${dst/#\~/$HOME}"
  check_link "$dst" "$src"
done < "$MAP"

echo
echo "== UserDefaults 快照 =="
if [ -f "$REPO/cmux/defaults.plist" ]; then
  tmp="$(mktemp)"
  python3 "$REPO/scripts/export-defaults.py" "$tmp" >/dev/null
  if diff -q "$tmp" "$REPO/cmux/defaults.plist" >/dev/null; then
    echo "✅ 与仓库快照一致"
  else
    echo "⚠️  当前值与仓库快照不同（改过设置？）——确认无误后跑 ./export-defaults.sh 更新快照"
  fi
  rm -f "$tmp"
else
  echo "跳过：没有 cmux/defaults.plist"
fi

echo
echo "== git 状态 =="
if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  if [ -z "$(git -C "$REPO" status --porcelain)" ]; then
    echo "✅ 仓库干净（所有改动都已提交）"
  else
    echo "⚠️  仓库有未提交改动："
    git -C "$REPO" status --porcelain | sed 's/^/    /'
  fi
else
  echo "提示：仓库尚未 git init"
fi

exit "$fail"
