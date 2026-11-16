# ghostty —— Ghostty 终端的配置

## 这个目录里有什么

| 文件 | 系统位置 | 谁在读 |
|---|---|---|
| `config` | `~/.config/ghostty/config` | **只有 Ghostty 读**（cmux 自 v0.65.2.2-r21 起已解耦，见下） |

## ⚠️ 只有 Ghostty 读这份配置；cmux 已解耦

2026-11-16 之前，cmux（基于 Ghostty 内核 libghostty 的终端）启动时会读
`~/.config/ghostty/config`，两个终端共用一份外观配置。**自 cmux v0.65.2.2-r21 起不再是**：
上游（cmux Issue #70）把两个应用的配置彻底解耦，cmux 只读它自己的
`~/.config/cmux/config.ghostty`。

所以：

- 改本文件只影响 **Ghostty**，cmux 不会有任何变化。
- 要让 cmux 也变，得在 `../cmux/config.ghostty` 里把同一个设置**再写一次**。
- 两边外观各自维护，**当前两份文件里共同项（主题、字体族、字号、光标、shell integration）
  的值是一致的**；`window-*` 与 `keybind` 只写在本文文件里，那是 Ghostty 独有的窗口行为。

## 当前内容要点

- 主题：GitHub Dark Default
- 字体：`Menlo` + 第二字体族 `PingFang SC`（`font-style = Bold`，普通文字默认加粗）
- 字号 14
- 光标：竖线、绿色、加粗到 300%
- 窗口尺寸与位置、Quick Terminal 全局热键、Cmd+V 粘贴剪贴板图片

`font-family = PingFang SC` 那一行不要删：显式两项字体族才构成「自己配的回退链」，
中文才会落到 PingFang SC Semibold。cmux 那边有同名的机制（没有回退链时会自动注入中文
`font-codepoint-map`，把中文钉死在 Regular），所以 `../cmux/config.ghostty` 里也写了同样的
两行。两份文件的注释里都有细节。
