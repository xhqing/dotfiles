# cmux —— cmux 终端的配置

## 这个目录里有什么

| 文件 | 系统位置 | 来源 / 特点 |
|---|---|---|
| `cmux.json` | `~/.config/cmux/cmux.json` | cmux 的**应用层设置**（外观、浏览器行为、侧边栏、快捷键、通知钩子、actions）。设置界面读它、也会写回它，是这一层的权威源。首次启动时 cmux 会自己生成一份全注释模板，我们的版本就是在这份模板上改的 |
| `config.ghostty` | `~/.config/cmux/config.ghostty` | cmux **自己的终端配置**（字体、字号、主题、光标、shell integration 等）。用的是 Ghostty 的配置语法，但只有 cmux 读它。v0.65.2.2-r21 起 cmux 不再读 `~/.config/ghostty/config`，终端外观只认这份文件 |
| `defaults.plist` | （不落地，安装时写进 `com.cmuxterm.app` 域） | UserDefaults 里属于「用户偏好」的一小撮，白名单见 `../scripts/export-defaults.py` |

## ⚠️ cmux 与 Ghostty 的配置已彻底解耦（cmux v0.65.2.2-r21 起）

**cmux 只读自己的 `~/.config/cmux/config.ghostty`；`../ghostty/config` 只影响 Ghostty。**

在此之前 cmux 基于 libghostty，启动时会读 `~/.config/ghostty/config`，两个终端共用一份外观配置。
自 v0.65.2.2-r21 起上游（cmux Issue #70）把两者解耦：cmux 不再读 Ghostty 的配置路径，
原有的外观设置如果不写进本目录的 `config.ghostty`，升级后就会全部落回默认——
方块光标、主题自带的光标色、默认字体（2026-11-16 用户升级到 r21 后就遇到过）。

所以现在的规则是：

- **两边外观各自维护**：同一个设置（主题、字体族、字号、光标）要在 `ghostty/config`
  与 `cmux/config.ghostty` 里**各写一次**，只改一份只有那一个终端变。
- 当前两份文件里这些共同项的值是一致的；`ghostty/config` 额外的窗口尺寸
  （`window-width` / `window-height` / `window-position-*`）与 `keybind` 只对 Ghostty 有意义，
  cmux 那份不重复。
- 改完 cmux 那份执行 `cmux reload-config` 生效（终端原地刷新，不用重启 App）；
  `./check.sh` 能查出软链是否还在。

## ⚠️ 一条已知的 cmux 行为（会影响中文观感）

当用户配置里**没有**多字体族回退链、也**没有**任何 `font-codepoint-map` 时，cmux 会自动
注入一组中日韩 `font-codepoint-map`，把中文钉到 `PingFang SC`。而 codepoint-map 在
Ghostty 内核里一律按 **Regular** 字重解析，结果是 cmux 的中文比 Ghostty 细一档。

这条行为现在只对 cmux 自己那份配置（`config.ghostty`）生效。对策同样是写在那里：
`font-family = Menlo` 后面再加一行 `font-family = PingFang SC`。两项以上就满足
「显式回退链」，cmux 停止注入，中文走正常回退（Semibold）。**不要删那一行。**

`ghostty/config` 里也有同样两行 `font-family`，原因相同（Ghostty 侧保持了同一套写法）。

## 没在这里的 cmux 数据

会话恢复、滚动历史、agent journal、浏览器历史、登录凭证、遥测 ID 都属于运行时数据，
不备份（新机器上重新生成）。
