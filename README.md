# dotfiles（cmux + Ghostty 终端配置）

把本机 cmux / Ghostty 的个人配置收在一个 git 仓库里，换设备时 clone 下来跑一次
`./install.sh` 就恢复成同一套习惯，不用重新点一遍设置。

## 目录结构

```
dotfiles/
├── ghostty/config          → 软链到 ~/.config/ghostty/config
├── cmux/cmux.json          → 软链到 ~/.config/cmux/cmux.json
├── cmux/config.ghostty     → 软链到 ~/Library/Application Support/com.cmuxterm.app/config.ghostty
├── cmux/defaults.plist     → cmux 的 UserDefaults 偏好快照（白名单，安装时写回）
├── install.sh              → 新机器部署：建软链 + 写回 UserDefaults
├── check.sh                → 检查软链是否还健在、快照是否过期、仓库是否干净
├── export-defaults.sh      → 改了设置后刷新 UserDefaults 快照
└── scripts/                → 上面两个脚本用到的 Python 小工具
```

## 新机器恢复步骤

```bash
git clone <本仓库地址> ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh          # 建软链 + 写回 UserDefaults + cmux reload-config
```

注意：

- `install.sh` 会先把目标位置上已存在的普通文件改名成 `xxx.bak.<时间戳>` 再建软链，不会覆盖丢东西。
- 装之前不需要先装 Ghostty：cmux 自己也读 `~/.config/ghostty/config`。
- 恢复后如果 cmux 已经在跑，手动 `cmux reload-config` 一次即可。

## 为什么要软链

配置只有一份实体，改一处两边同步，不会出现「仓库里是旧版本」的漂移。

cmux 对这三个文件的写入都是跟随软链的（写前 `resolvingSymlinksInPath` 再落盘），
所以不会把软链替换成普通文件；万一将来某个版本改了写入方式，`./check.sh` 会报
「不是软链」，跑一次 `./install.sh` 修好即可。

## 备份了什么、没备份什么

**备份（配置）**

- `~/.config/ghostty/config`：终端层全部设置——字体族与字号、`font-style = Bold`、
  主题、光标样式与粗细、窗口尺寸与位置、Quick Terminal 热键、粘贴图片的 keybind。
- `~/.config/cmux/cmux.json`：cmux 应用层设置（外观、浏览器行为、侧边栏外观、
  快捷键、通知钩子、actions 等；当前文件大部分是模板注释，生效的只有几项）。
- `~/Library/Application Support/com.cmuxterm.app/config.ghostty`：在 cmux
  设置界面里改终端选项（字体、光标、内边距、透明度、scrollback 等）时写的覆盖文件，
  它在用户自己的 Ghostty 配置之后加载。仓库里常驻一个只带注释的同名文件，安装时
  就把软链接好；以后在 cmux 设置里改东西，改动会直接落进仓库，`git status` 立刻能看见。
- `cmux/defaults.plist`：UserDefaults 里属于「用户偏好」的那一小撮（外观模式、
  侧边栏样式、右侧栏模式、文件浏览器宽度等），白名单见 `scripts/export-defaults.py`。

**不备份（有意排除）**

- 登录凭证、keychain token、`credentials.json`、`cmux.auth.*`、遥测 / 安装 ID。
- 运行时数据：会话与工作区快照、滚动历史、agent journal、浏览器历史、搜索索引、
  窗口位置（`NSWindow Frame …`）、`closed-item-history`。
- 别的工具的配置（`~/.zshrc` 等），需要时可另开仓库管理。

## 已知注意点

- **中文字体那件事**：`ghostty/config` 里 `font-family = Menlo` 之后又写了一行
  `font-family = PingFang SC`。这一行不是装饰——cmux 在「用户没配多字体族回退链」时
  会自动把中文钉到 PingFang SC **Regular**，看起来比 Ghostty 细一档。加上第二字体族
  后 cmux 停止注入，两个终端的中文都走正常回退（Semibold），外观一致。细节见该文件里的注释。
- **权限**：`cmux.json` 里可能写 socket 控制密码，文件保持 600（仅本人可读）。
- **同一仓库不要两台机器同时改**（本项目会经 macmini 双向镜像同步）：镜像会同步 git
  元数据，两边同时写容易让 `.git` 冲突。改配置只在一台机器上做，改完提交。
- **cmux 版本升级**可能迁移 `cmux.json` 的 `schemaVersion`。升级后跑一次 `./check.sh`，
  确认软链还在、仓库改动已提交。
