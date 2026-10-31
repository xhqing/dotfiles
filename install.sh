#!/usr/bin/env bash
# 把本仓库的配置部署到这台机器上：按 mappings.conf 建软链 + 写回 UserDefaults 快照 + 提示重载。
#
# 新机器上的用法（clone 之后）：
#   ./install.sh
#
# 脚本是幂等的，重复跑只会重新指向软链，不会重复备份；已存在且不是软链的原文件
# 会被改名成 xxx.bak.<时间戳> 保留下来。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAP="$REPO/mappings.conf"

# link <仓库内相对路径> <系统目标路径> <权限|->
link() {
  local src="$REPO/$1"
  local dst="$2"
  local mode="$3"

  if [ ! -e "$src" ]; then
    echo "跳过：仓库里没有 $1"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"

  # 目标已存在且不是软链 → 先备份再替换，避免弄丢用户已有的配置
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local bak="$dst.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$bak"
    echo "备份 $dst -> $bak"
  fi

  ln -sfn "$src" "$dst"
  if [ "$mode" != "-" ] && [ -n "$mode" ]; then
    chmod "$mode" "$src"
  fi
  echo "链接 $dst -> $src"
}

echo "== 1. 按 App 建软链 =="
while IFS=$'\t' read -r src dst mode note; do
  case "$src" in
    ''|'#'*) continue ;;
  esac
  dst="${dst/#\~/$HOME}"
  [ -n "$note" ] && echo "  ($note)"
  link "$src" "$dst" "$mode"
done < "$MAP"

echo
echo "== 2. cmux 的 UserDefaults 快照 =="
if [ -f "$REPO/cmux/defaults.plist" ]; then
  python3 "$REPO/scripts/apply-defaults.py"
else
  echo "跳过：仓库里没有 cmux/defaults.plist"
fi

echo
echo "== 3. 生效 =="
if command -v cmux >/dev/null 2>&1; then
  cmux reload-config >/dev/null 2>&1 && echo "已执行 cmux reload-config" || echo "提示：cmux reload-config 失败，可手动重载"
else
  echo "提示：本机尚未安装 cmux，装好后执行 cmux reload-config"
fi

echo
echo "完成。"
