#!/usr/bin/env bash
# 把本机当前的 cmux UserDefaults 值重新导出成仓库里的快照（改了设置之后跑一次）。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$REPO/scripts/export-defaults.py"
echo
echo "提示：快照有变化的话记得提交（./check.sh 可确认状态）"
