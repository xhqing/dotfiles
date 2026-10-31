# ghostty —— Ghostty 终端的配置

## 这个目录里有什么

| 文件 | 系统位置 | 谁在读 |
|---|---|---|
| `config` | `~/.config/ghostty/config` | **Ghostty 和 cmux 两个 App 都读**（见下） |

## ⚠️ 共用文件：`config`

`config` 是**一套配置、两个终端在用**：

- **Ghostty**（独立终端）：正常读取自己的配置。
- **cmux**（基于 Ghostty 内核 libghostty 的终端）：启动时同样读这个文件，
  所以字体、字号、主题、光标、窗口行为这些设置**两边自动一致**。

改这里会**同时改变两个终端的观感**。如果只想影响 cmux，不要改这里，
改 `../cmux/config.ghostty`（那个文件只有 cmux 读，且加载顺序在它之后，能覆盖本文件）。

反过来，如果只想影响 Ghostty、不影响 cmux，那做不到——cmux 一定会读这份配置。

## 当前内容要点

- 主题：GitHub Dark Default
- 字体：`Menlo` + 第二字体族 `PingFang SC`（`font-style = Bold`，普通文字默认加粗）
- 字号 14
- 光标：竖线、绿色、加粗到 300%
- 窗口尺寸与位置、Quick Terminal 全局热键、Cmd+V 粘贴剪贴板图片

`font-family = PingFang SC` 那一行不要删：它是为了让 cmux 停止自动注入中文
`font-codepoint-map`（那份注入会把中文钉死在 PingFang SC Regular，比 Ghostty 细一档）。
细节见该文件里的注释。
