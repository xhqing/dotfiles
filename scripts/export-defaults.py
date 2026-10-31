#!/usr/bin/env python3
"""把本机 cmux 的 UserDefaults 快照收进仓库（只导白名单里的用户设置项）。

为什么只导白名单：com.cmuxterm.app 这个域里有 90 多个 key，绝大多数是运行时状态
（窗口位置、会话、遥测 ID、登录缓存、浏览器 profile 等）或不适合跨机器搬运的标识。
逐项挑出「属于用户偏好」的那些导出，既不丢配置，也不会把凭证/遥测 ID 带进仓库。

用法：python3 scripts/export-defaults.py [输出路径]
默认输出到仓库的 cmux/defaults.plist。
"""

import os
import plistlib
import subprocess
import sys

DOMAIN = "com.cmuxterm.app"

# 白名单：只列「用户偏好」性质的 key。新增项请先确认它不是状态/凭证/遥测。
WHITELIST = [
    # 外观
    "appearanceMode",
    "browserThemeMode",
    "confirmQuit",
    "cmuxDisableBundleIconPersistence",
    "SUEnableAutomaticChecks",
    # 侧边栏外观
    "sidebarPreset",
    "sidebarMaterial",
    "sidebarBlendMode",
    "sidebarBlurOpacity",
    "sidebarCornerRadius",
    "sidebarMatchTerminalBackground",
    "sidebarTintHex",
    "sidebarTintOpacity",
    "sidebarAppearanceDefaultsVersion",
    # 右侧栏与文件浏览器
    # 注意：fileExplorer.isVisible 故意不收——它只是「侧栏此刻开没开」的瞬时状态，
    # 不属用户偏好；收进来会让 check.sh 因为开关一次侧栏就报「快照过期」。
    "rightSidebar.mode",
    "fileExplorer.width",
]

# 明确排除（写在这里是为了让后来者一眼看到：这些永远不进仓库）
EXCLUDED_HINTS = (
    "cmux.auth", "posthog", "cmux.telemetry", "mobileHost", "browserProfiles",
    "cmux.analytics", "cloudTree", "sessionIndex", "NSWindow Frame",
)


def normalize(key: str, value):
    """把浮点值圆整到 6 位小数。

    为什么要这一步：`defaults write -float` 只能存 32 位浮点，0.18 写进去会变成
    0.18000000715255737。如果快照里保留原始 double，每次 export / 写回都会因为这点
    精度差异让 check.sh 误报「改过设置」。圆整到 6 位对 UI 上的取值没有实际影响。
    """
    if isinstance(value, float):
        return round(value, 6)
    return value


def main() -> int:
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(repo_root, "cmux", "defaults.plist")

    raw = subprocess.run(
        ["defaults", "export", DOMAIN, "-"], capture_output=True, check=True
    ).stdout
    current = plistlib.loads(raw)

    snapshot = {k: normalize(k, current[k]) for k in WHITELIST if k in current}

    dropped = [k for k in current if any(h in k for h in EXCLUDED_HINTS)]
    if dropped:
        print(f"已排除 {len(dropped)} 个状态/凭证类 key（不进仓库）")

    with open(out_path, "wb") as fh:
        plistlib.dump(snapshot, fh)
    os.chmod(out_path, 0o644)

    print(f"已写入 {out_path}（{len(snapshot)} 项）")
    for k, v in snapshot.items():
        print(f"  {k} = {v!r}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
