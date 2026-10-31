#!/usr/bin/env python3
"""把仓库里的 cmux UserDefaults 快照写回本机。

只写白名单快照里出现过的 key，不碰新机器上已有的登录缓存、遥测 ID、窗口位置等状态。

用法：python3 scripts/apply-defaults.py [快照路径]
默认读取仓库的 cmux/defaults.plist。
"""

import os
import plistlib
import subprocess
import sys

DOMAIN = "com.cmuxterm.app"


def defaults_write(key: str, value) -> None:
    """按 Python 类型选 defaults 的类型开关。"""
    if isinstance(value, bool):
        # bool 必须先判断：Python 里 bool 是 int 的子类
        args = ["-bool", "true" if value else "false"]
    elif isinstance(value, int):
        args = ["-int", str(value)]
    elif isinstance(value, float):
        args = ["-float", repr(value)]
    elif isinstance(value, str):
        args = ["-string", value]
    else:
        raise TypeError(f"不支持的 value 类型：{key} = {value!r}")

    subprocess.run(["defaults", "write", DOMAIN, key] + args, check=True)
    print(f"  {key} = {value!r}")


def main() -> int:
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(repo_root, "cmux", "defaults.plist")

    if not os.path.exists(src):
        print(f"跳过：{src} 不存在（没有 UserDefaults 快照）")
        return 0

    with open(src, "rb") as fh:
        snapshot = plistlib.load(fh)

    print(f"写入 {len(snapshot)} 项 UserDefaults 到 {DOMAIN}：")
    for key, value in snapshot.items():
        defaults_write(key, value)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
