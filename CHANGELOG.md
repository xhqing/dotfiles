# 更新日志

## 0.2.0 — 2026-10-31

### 变更

- 按 App 重新组织目录：`ghostty/`、`cmux/` 各一个目录，每个目录带一份 `README.md` 说明该 App 的配置构成与读它的程序。
- 新增 `mappings.conf`：用「仓库内路径 → 系统目标路径 → 权限 → 说明」的表格描述部署关系，`install.sh` 与 `check.sh` 都读它；以后新增 App 只改这一张表，不用动脚本。
- `install.sh` / `check.sh` 改为遍历映射表，输出里带每条的用途说明。

### 新增

- 根 README 增加「共用配置文件（重要）」章节与表格：明确 `ghostty/config` 同时被 **Ghostty 与 cmux** 读取（cmux 基于 libghostty，读同一份配置），`cmux/config.ghostty` 虽是 Ghostty 语法但**只有 cmux** 读；并写明新增 App 时同步该表的要求。
- `ghostty/README.md`、`cmux/README.md`：分别说明本目录文件、跨 App 共用关系、cmux 的中文 codepoint-map 注入行为与对策。
- `ghostty/config` 文件头加共用标注（哪个程序在读、只想影响 cmux 该改哪里）。
- `cmux/config.ghostty` 文件头补「Ghostty 语法但只有 cmux 读」的两句话说明。

### 仓库治理

- `fileExplorer.isVisible` 从 UserDefaults 白名单移除：它只是「侧栏此刻开没开」的瞬时状态，不是偏好；收进来会让 `check.sh` 因为开关一次侧栏就误报「快照过期」。宽度 `fileExplorer.width` 仍保留。

- 本项目登记为 Kit（ExecutiveAssistantAgent）的子项目：全局 `agents-registry.md` 子项目映射表、本项目 `AGENTS.md` 子项目清单同步新增。
- 仓库根挂 `AGENTS.md` 软链接（→ `../ExecutiveAssistantAgent/AGENTS.md`）与真实 `.pi/` 目录（`settings.json` 用路径引用 Kit 项目的 extensions / skills / prompts / themes），随仓库提交。
- `xhqing` 公开名册暂不同步（私有仓库，公开描述语待用户确认），在 roster-sync 的 `allowlist.json` 登记豁免。

## 0.1.0 — 2026-10-31

### 新增

- 建立仓库：把 cmux / Ghostty 的个人配置集中到一处，换设备 clone 后跑 `install.sh` 即可恢复。
  - `ghostty/config`：终端层设置（字体族、字号、加粗样式、主题、光标、窗口尺寸、Quick Terminal 热键、粘贴图片 keybind）。
  - `cmux/cmux.json`：cmux 应用层设置（外观、浏览器行为、侧边栏外观等）。
  - `cmux/config.ghostty`：cmux 设置界面写出的终端覆盖文件。仓库里常驻一个只带注释的同名文件并始终接上软链，以后在 cmux 设置里改字体 / 光标 / 内边距等，改动直接落进仓库。
  - `cmux/defaults.plist`：UserDefaults 里属于用户偏好的白名单快照（外观模式、侧边栏样式、右侧栏模式、文件浏览器宽度等），排除登录凭证、遥测 ID、会话与窗口状态。
- `install.sh`：幂等部署脚本，把配置文件改为指向仓库的软链（原文件先改名备份），并写回 UserDefaults 快照，最后 `cmux reload-config`。
- `check.sh`：检查软链是否完好、UserDefaults 快照是否过期、仓库是否干净。
- `export-defaults.sh` + `scripts/*.py`：刷新 UserDefaults 快照的导出 / 写回工具，白名单在 `scripts/export-defaults.py` 里显式维护。

### 说明

- cmux 对 `cmux.json` 与 App Support `config.ghostty` 的写入都会先解析软链再落盘，因此软链方案是安全的；若将来某个版本改成原子写替换，`check.sh` 会报「不是软链」。
- cmux 设置界面里的字体下拉框只列等宽字体，且写入时是「清空 + 单族」，无法产生多字体族回退链；本仓库的 `ghostty/config` 用两行 `font-family` 让 cmux 停止注入中文 codepoint-map，两个终端的中文观感才一致。
