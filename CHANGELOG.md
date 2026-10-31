# 更新日志

## 0.1.0 — 2026-10-31

### 新增

- 建立仓库：把 cmux / Ghostty 的个人配置集中到一处，换设备 clone 后跑 `install.sh` 即可恢复。
  - `ghostty/config`：终端层设置（字体族、字号、加粗样式、主题、光标、窗口尺寸、Quick Terminal 热键、粘贴图片 keybind）。
  - `cmux/cmux.json`：cmux 应用层设置（外观、浏览器行为、侧边栏外观等）。
  - `cmux/config.ghostty`：cmux 设置界面写出的终端覆盖文件（本机目前不存在，`install.sh` 会自动跳过）。
  - `cmux/defaults.plist`：UserDefaults 里属于用户偏好的白名单快照（外观模式、侧边栏样式、右侧栏模式、文件浏览器宽度等），排除登录凭证、遥测 ID、会话与窗口状态。
- `install.sh`：幂等部署脚本，把配置文件改为指向仓库的软链（原文件先改名备份），并写回 UserDefaults 快照，最后 `cmux reload-config`。
- `check.sh`：检查软链是否完好、UserDefaults 快照是否过期、仓库是否干净。
- `export-defaults.sh` + `scripts/*.py`：刷新 UserDefaults 快照的导出 / 写回工具，白名单在 `scripts/export-defaults.py` 里显式维护。

### 说明

- cmux 对 `cmux.json` 与 App Support `config.ghostty` 的写入都会先解析软链再落盘，因此软链方案是安全的；若将来某个版本改成原子写替换，`check.sh` 会报「不是软链」。
- cmux 设置界面里的字体下拉框只列等宽字体，且写入时是「清空 + 单族」，无法产生多字体族回退链；本仓库的 `ghostty/config` 用两行 `font-family` 让 cmux 停止注入中文 codepoint-map，两个终端的中文观感才一致。
