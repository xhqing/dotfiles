# 更新日志

### 变更（Kit 项目更名为 assistant-agent，2026-11-09）

- **为什么改**：Kit 的 Agent 项目 2026-11-09 由 `ExecutiveAssistantAgent` 更名为 `assistant-agent`——项目名只求「尽可能简单、能体现主要职责」，不再要求以 `Agent` 结尾；项目性质改由 `README.md` 的 `Type-AI Agent` 徽章判定，与名字无关。本仓库是 Kit 名下的子项目，`AGENTS.md` 的归属说明用旧名就会指错对象。
- **改了什么**：`AGENTS.md` 两处指代（文件头「某 Agent 名下的子项目」与「归谁负责」段）由 `ExecutiveAssistantAgent（Kit）` 改为 `assistant-agent（Kit）`。

### 新增（CI 门禁：validate 检查 + main 分支 strict 保护）

- **为什么改**：用户 2026-11-03 立规「新建仓库一律必须 strict 模式的 PR CI」，并要求 28 个不合规的存量仓库统一执行最新标准。本项目此前在 PR 上没有门禁——改动合进 main 全靠人工把关，PR 可以拿旧 main 上通过的检查直接合并，回归防护存在缺口。本次补齐团队要求的「三件套」：PR 上真实跑的 CI 检查 + 挂成 required status check + `required_status_checks.strict = true`。
- **改了什么**（2026-11-03）：新增 `.github/workflows/validate.yml`（PR 与 main push 触发，检查名 `validate`）与 `.github/scripts/validate.py`（仓库卫生检查：必备文件存在、敏感文件未被跟踪、被跟踪文件不超过 10 MB、README 相对链接有效、Python / Shell 语法检查）；main 分支保护补挂 required check `validate` 并设 `strict=true`。
- **边界**：检查只做确定性、低误报的项目（required check 一旦误报就会卡住正常 PR，所以宁可少查）；不改动仓库任何原有内容。

## 未发布

### 新增（项目标配补齐：LICENSE / 双语 README / LOGO / About / CONTRIBUTING）

- **为什么改**：commit skill 第 9 步的标配检测发现本项目缺了几项应有内容——没有 `LICENSE.md`（也就算不出许可证徽章）、只有中文 `README.md`（无 `README_cn.md` 与英文版）、README 无 LOGO / 徽章 / 版权署名段、GitHub About 空白、两份 CONTRIBUTING 还是「软件用 MIT、非软件用 CC BY 4.0」的通用模板（没落到本项目实际许可证）。
- **改了什么**：
  - 新增 `LICENSE.md`（MIT 全文，版权行 `Copyright (c) 2026 xhqing and contributors`）。性质判定：配置文件的消费方是 Ghostty / cmux 等程序、改动直接改变程序行为，属软件项目 → MIT。
  - 新增 `assets/logo.svg`（640×200、圆角 28、青绿渐变、终端窗口象征图形 + 英文项目名与副标题；文字边界校验 PASS）。
  - `README.md` 改为英文版，原中文内容落到新增的 `README_cn.md`；两版顶部各加居中 LOGO + License / Version / Type 三枚徽章 + 语言互链，底部加「版权与署名」段。正文语义与改动前一致（含 cmux r21 解耦口径）。
  - `CONTRIBUTING.md` / `CONTRIBUTING_cn.md` 按全局模板重写，许可证名替换为 MIT。
  - GitHub About 补中英双语 description 与 5 个 topics（dotfiles / macos / ghostty / terminal / configuration-management）。
  - 新增 `.commit-cache.md`：commit skill 的标配就绪标记与预检审计（不含任何敏感信息）。
- **回归检查**：`README_cn.md` 正文即改动前的 `README.md` 内容（仅顶部 LOGO / 徽章块与底部版权段是新增）；`.github/scripts/validate.py` 全绿（必备文件、相对链接、语法）；`./install.sh` / `./check.sh` 未改动。

### 变更（cmux v0.65.2.2-r21 配置解耦，2026-11-16）

- **为什么改**：cmux 自 v0.65.2.2-r21 起不再读 `~/.config/ghostty/config`（上游 Issue #70 把两个应用的配置彻底解耦），终端外观只认它自己的 `~/.config/cmux/config.ghostty`。仓库里原来的部署目标（App Support 下的 `config.ghostty`）与全套文档口径随之失效——用户升级到 r21 后光标变回方块、字体回到默认，就是这份配置没跟上导致的。
- **改了什么**：
  - `cmux/config.ghostty` 整体重写：从「只留注释的占位文件」改为声明式终端配置（主题 `GitHub Dark Default`、`Menlo` + `PingFang SC` + Bold、字号 14、绿色竖线光标 + 300% 粗细、`shell-integration-features` 固定光标），并写明「r21 起 cmux 只读这份」「改完 `cmux reload-config`」。
  - `mappings.conf`：`cmux/config.ghostty` 的目标路径由 `~/Library/Application Support/com.cmuxterm.app/config.ghostty` 改为 `~/.config/cmux/config.ghostty`；`ghostty/config` 的说明由「被 Ghostty 与 cmux 共用」改为「只有 Ghostty 读」。
  - `cmux/README.md`：表格里的系统位置更新；原「两条跨 App 关系」整节重写为「配置已彻底解耦」；中文 `font-codepoint-map` 行为说明限定为「只对 cmux 自己那份配置生效」。
  - `ghostty/config`：文件头注释与中文回退链说明由「共用文件」改为「只被 Ghostty 读」，并注明 cmux 那份里写了同样的两行。
  - `ghostty/README.md`：「⚠️ 共用文件」节重写为「只有 Ghostty 读；cmux 已解耦」，说明两边外观各自维护、当前共同项（主题 / 字体族 / 字号 / 光标 / shell integration）值一致。
  - 根 `README.md`：「共用配置文件」表改为「配置文件归属」表（当前无跨 App 共用项）、目录结构注释、新机器恢复步骤、日常维护表、「为什么不直接复制」、「已知注意点」一并更新；「两台机器不要同时写」不再依赖已废止的「`~/Developer` 全量镜像」口径。
- **回归检查**：Ghostty 侧行为不变（`ghostty/config` 只改注释，键值一字未动，`ghostty +show-config` 输出不变）；cmux 侧恢复光标与字体（`cmux config paths` 的 Related 项指向 `~/.config/cmux/config.ghostty`，与 `mappings.conf` 一致；用 cmux 自带的 Ghostty 解析器验过 `cursor-style = bar` / `cursor-color = #00ff00` / `adjust-cursor-thickness = 300%` / `font-size = 14` / `theme = GitHub Dark Default` 均被读到）。
- **顺带修复**：`.pi/APPEND_SYSTEM.md` 在 2026-11-09 的「子项目与 Agent 项目完全解耦」提交（`57ae897`）里被一次错误替换吞掉正文——多处段落变成重复的同一句模板，`## 这是什么`、核心机制第 1 / 3 条、`## 不许破坏的既有行为` 第 3 条、`## 验证方式` 的代码块全部丢失。本次按该文件首次加入时的版本（`eef7187`）恢复，并按新口径更新「配置文件归属」一节与中文回退链一条。

### 新增（子项目专属规则文件 `.pi/APPEND_SYSTEM.md`）

- **为什么改**：用户 2026-11-07 定下全局 Leader / Worker 分工——子项目的具体活由「以子项目根目录 / 子项目 worktree 为工作目录」的 Worker 会话干，而 pi 只加载 cwd 那一层的 `.pi/`（不向上继承）。子项目专属的硬规则没有别的地方可放：写进 Agent 项目的 `AGENTS.md` 既不会被 Worker 加载，也会污染其它兄弟子项目。
- **改了什么**：新增 `.pi/APPEND_SYSTEM.md`（52 行），只写本项目特有的硬约束——「实体只存一份 + 软链 + `mappings.conf` 单一登记」的核心机制不可改、新增 App 的固定六步、共用配置文件必须显式注明（目前只有 `ghostty/config`）、不许破坏的既有行为（中文回退链 `font-family = PingFang SC`、`cmux.json` 600、`defaults.plist` 白名单备份）、公开仓库的敏感信息边界（登录凭证 / keychain token / 遥测 ID / 会话快照不进仓库，socket 密码只写占位符）、`./check.sh` 三处全绿才算改完。全局规则与 Kit 身份仍来自仓库根 `AGENTS.md` 软链接，文件里不重述、不覆盖。
- **影响**：纯新增规则文件，不改 `mappings.conf`、`install.sh`、`check.sh` 与任何 App 配置；不涉版本号（配置 / 文档类不发版）。

### 仓库治理

- **`.gitignore` 补 Python 缓存规则**（2026-11-05）：新增 `__pycache__/` 与 `*.pyc`。
  - 起因：`scripts/` 下跑过 Python 脚本后生成了未跟踪目录 `scripts/__pycache__/`（`git status` 显示 `?? scripts/__pycache__/`），说明 `.gitignore` 漏了 Python 缓存，存在被误提交的风险。
  - 改了什么：`.gitignore` 末尾加「Python 缓存」小节，含 `__pycache__/`（目录，任意层级）与 `*.pyc`（单个字节码文件）。

### 变更

- **cmux 打字延迟治理**（2026-11-03）：`cmux/cmux.json` 关闭通知相关的「逐字触发」与「通知页重绘」开关——`notifications.paneFlashOnTyping` / `paneFlash` / `paneFlashDoubleBlink` / `unreadPaneRing` 全部置 `false`，`sidebar.showNotificationMessage` 置 `false`，`app.reorderOnNotification` 置 `false`，`automation.suppressSubagentNotifications` 置 `true`。
  - 起因：在 cmux 里用 pi 打字明显卡顿，而同一台机器上的 Ghostty 原生终端不卡。排查后确认问题不在本机资源（内存压力两个终端共享同一份，Ghostty 不卡即排除），而在 cmux 自己的通知链路：上游 issue #8900（S2 级，至今未修复）中 `NotificationsPage` 与已挂载 workspace 同处一个 ZStack，只靠 `opacity(0)` 隐藏、从不卸载，agent 每流式输出一次就在主线程重跑页面 body 并重建 MarkdownUI feed；再叠加官方 schema 里 `paneFlashOnTyping` 默认 `true`（含义是「打字消除本 pane 的通知时闪烁该 pane」），卡顿就正好落在开始打字那一瞬间。
  - 通知本身保留：侧栏未读标记、Dock 角标都不受影响，只是不再为它重绘整块面板。

- **cmux 控制 socket 放开到 `automation` 档**（2026-11-07）：`cmux/cmux.json` 新增 `automation.socketControlMode: "automation"`。
  - 起因：pi 的 diff-view 扩展（`/open-diff`）在 Ghostty 里跑的 pi 会话中被 cmux 拒绝，报 `Access denied - only processes started inside cmux can connect`——cmux 的自动化 socket 默认 `cmuxOnly`，只接受「cmux 自己启动的进程树」，而 Ghostty 里的 pi 不属于那棵树。
  - 改了什么：档位改成 `automation`（同一 macOS 用户的本地进程都能连控制 socket），外部终端才能驱动 cmux（diff 面板、脚本）。
  - 代价：本机任何同用户进程都能控制 cmux（包括往终端里发命令）。共用机器或不放心时改回 `cmuxOnly`，改成在 cmux 里启动 pi。

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
- 已建私有远程仓库 <https://github.com/xhqing/dotfiles>（2026-10-31，用户授权），README 恢复步骤里的地址改为实际地址。
- 按用户 2026-10-31 的新指示，公开名册改为与全局注册表实时同步（不再逐次征询），dotfiles 已写入 `xhqing` 中英名册，原 allowlist 豁免已删除。

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
