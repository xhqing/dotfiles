# cmux —— cmux 终端的配置

## 这个目录里有什么

| 文件 | 系统位置 | 来源 / 特点 |
|---|---|---|
| `cmux.json` | `~/.config/cmux/cmux.json` | cmux 的**应用层设置**（外观、浏览器行为、侧边栏、快捷键、通知钩子、actions）。设置界面读它、也会写回它，是这一层的权威源。首次启动时 cmux 会自己生成一份全注释模板，我们的版本就是在这份模板上改的 |
| `config.ghostty` | `~/Library/Application Support/com.cmuxterm.app/config.ghostty` | **cmux 设置界面**里改终端选项（字体、光标、内边距、透明度、scrollback 等）时写出的覆盖文件。加载顺序在 `~/.config/ghostty/config` **之后**，能覆盖同名键 |
| `defaults.plist` | （不落地，安装时写进 `com.cmuxterm.app` 域） | UserDefaults 里属于「用户偏好」的一小撮，白名单见 `../scripts/export-defaults.py` |

## ⚠️ 这里有两条「跨 App」的关系

**1. cmux 会读 `../ghostty/config`（Ghostty 的配置文件）。**

cmux 基于 libghostty，启动时读的就是 `~/.config/ghostty/config`。所以：

- 那个文件是**共用文件**，改它两个终端一起变（列表见根 README 的「共用配置文件」）。
- 想只影响 cmux，就写本目录的 `config.ghostty`（它在共用配置之后加载）。
- 想只影响 Ghostty、不影响 cmux：做不到。

**2. `config.ghostty` 用的是 Ghostty 的语法，但只有 cmux 读它。**

它放在 cmux 自己的 Application Support 目录下，Ghostty 应用不会去读这个路径。
所以「Ghostty 格式」不等于「Ghostty 会用」——这是最容易搞混的一点。

## ⚠️ 一条已知的 cmux 行为（会影响中文观感）

当用户配置里**没有**多字体族回退链、也**没有**任何 `font-codepoint-map` 时，cmux 会自动
注入一组中日韩 `font-codepoint-map`，把中文钉到 `PingFang SC`。而 codepoint-map 在
Ghostty 内核里一律按 **Regular** 字重解析，结果是 cmux 的中文比 Ghostty 细一档。

对策写在 `../ghostty/config`：`font-family = Menlo` 后面再加一行 `font-family = PingFang SC`。
两项以上就满足「显式回退链」，cmux 停止注入，两个终端的中文都走正常回退（Semibold）。
**不要删那一行。**

## 没在这里的 cmux 数据

会话恢复、滚动历史、agent journal、浏览器历史、登录凭证、遥测 ID 都属于运行时数据，
不备份（新机器上重新生成）。
