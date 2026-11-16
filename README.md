# dotfiles（按 App 分类的配置文件仓库）

把这台机器上值得带走的 App 配置收在一个 git 仓库里，换设备时 clone 下来跑一次
`./install.sh` 就恢复成同一套习惯，不用重新点一遍设置。

## 目录结构

```
dotfiles/
├── mappings.conf           # 仓库内路径 → 系统路径 的映射表（install / check 共用，加 App 只改这里）
├── ghostty/                # App：Ghostty 终端
│   ├── README.md           #   本目录的 config 只被 Ghostty 读，见下
│   └── config              #   → ~/.config/ghostty/config
├── cmux/                   # App：cmux 终端
│   ├── README.md           #   ⚠️ cmux 自 r21 起只读自己的终端配置，见下
│   ├── cmux.json           #   → ~/.config/cmux/cmux.json
│   ├── config.ghostty      #   → ~/.config/cmux/config.ghostty
│   └── defaults.plist      #   cmux 的 UserDefaults 偏好快照（安装时写回，不落软链）
├── install.sh              # 新机器部署：按映射表建软链 + 写回快照 + cmux reload-config
├── check.sh                # 检查软链 / 快照 / 仓库状态
├── export-defaults.sh      # 改了设置后刷新 UserDefaults 快照
└── scripts/                # 上面那个快照用到的导出 / 写回工具
```

## 配置文件归属（重要）

物理文件只存仓库一份，按 App 放在自己的目录里，然后把「谁在读」记在这里——
**新增或改动这类文件时必须同步本表与相关目录 README**。

| 仓库内文件 | 系统位置 | 谁在读 | 说明 |
|---|---|---|---|
| `ghostty/config` | `~/.config/ghostty/config` | **只有 Ghostty** | Ghostty 的终端配置（主题、字体、字号、光标、窗口尺寸、Quick Terminal 热键） |
| `cmux/config.ghostty` | `~/.config/cmux/config.ghostty` | **只有 cmux** | cmux 自己的终端配置，用 Ghostty 语法——「Ghostty 格式」≠「Ghostty 会用」。自 cmux v0.65.2.2-r21 起 cmux 不再读 `ghostty/config`，外观只认这份 |
| `cmux/cmux.json` | `~/.config/cmux/cmux.json` | **只有 cmux** | 应用层设置，设置界面读它也会写回 |
| `cmux/defaults.plist` | `com.cmuxterm.app` 的 UserDefaults 域 | **只有 cmux** | 偏好快照，安装时写回，不建软链 |

一句话记忆：**当前没有跨 App 共用的配置文件**。cmux 与 Ghostty 的终端配置已彻底解耦
（cmux v0.65.2.2-r21 起，Issue #70），同一个外观设置要在两份文件里各写一次。

## 新机器恢复步骤

```bash
git clone git@github.com:xhqing/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh          # 建软链 + 写回 UserDefaults + cmux reload-config
```

注意：

- `install.sh` 会把目标位置上已存在的普通文件改名成 `xxx.bak.<时间戳>` 再建软链，不会覆盖丢东西。
- 装之前不需要先装 Ghostty：cmux 自 v0.65.2.2-r21 起只读自己的 `~/.config/cmux/config.ghostty`，不依赖 `~/.config/ghostty/config`。
- 恢复后如果 cmux 已经在跑，手动 `cmux reload-config` 一次即可。

## 日常维护

| 改了什么 | 怎么进仓库 |
|---|---|
| Ghostty 的终端设置（字体、主题、光标…） | 直接编辑 `~/.config/ghostty/config`（其实是仓库文件）→ `git commit` |
| cmux 的终端设置（字体、主题、光标…） | 直接编辑 `~/.config/cmux/config.ghostty`（其实是仓库文件）→ `cmux reload-config` → `git commit`；想让两个终端一致时，同一个值要在两份文件里各写一次 |
| cmux 设置界面里的终端选项 | 写进 `~/.config/cmux/config.ghostty`（仓库文件）→ `git status` 能看到 → `git commit` |
| cmux.json / UI 里的偏好 | 改完跑 `./export-defaults.sh` → `git commit` |

不确定状态时跑 `./check.sh`：软链断了、快照过期、仓库有未提交改动都会报出来。

## 新增一个 App 的配置

1. 建目录 `apps 名字/`（简称、全小写）；
2. 把配置文件放进去；
3. 在 `mappings.conf` 加一行：`仓库内路径 <TAB> 系统目标路径 <TAB> 权限或 - <TAB> 说明`；
4. 在目录里写 `README.md`：这份配置是什么、谁在读、**有没有别的 App 也读它**；
5. 如果确实有多个 App 共用同一份文件，同步更新上面的「配置文件归属」表；
6. 跑 `./install.sh` 接上软链，`./check.sh` 确认全绿，然后提交。

## 为什么不直接复制、要建软链

配置只有一份实体，改一处两边同步，不会出现「仓库里是旧版本」的漂移。

cmux 对 `cmux.json` 的写入会先解析软链再落盘（源码里 `resolvingSymlinksInPath` 后才写）；
`config.ghostty` 现在也是软链，万一某个版本改成原子写替换（链接变成普通文件），
`./check.sh` 会报「不是软链」，跑一次 `./install.sh` 修好。

## 备份了什么、没备份什么

**备份（配置）**：`ghostty/config`、`cmux/cmux.json`、`cmux/config.ghostty`、
`cmux/defaults.plist`（外观模式、侧边栏样式、右侧栏模式、文件浏览器宽度等白名单项）。

**不备份（有意排除）**：登录凭证与 keychain token、遥测 / 安装 ID、会话与工作区快照、
滚动历史、agent journal、浏览器历史、窗口位置，以及别的工具的配置（需要时另开目录管理）。

## 已知注意点

- **中文观感**：`ghostty/config` 与 `cmux/config.ghostty` 里都是 `font-family = Menlo` 之后
  再加一行 `font-family = PingFang SC`，两份都不能删。cmux 在用户没有多字体族回退链时，
  会自动把中文钉到 `PingFang SC Regular`，比 Ghostty 细一档；显式写了回退链就不注入。
  详见 `ghostty/README.md`、`cmux/README.md`。
- **权限**：`cmux.json` 里可能写 socket 控制密码，文件保持 600（仅本人可读）。
- **两台机器不要同时写**：同一仓库同一时间只在一台机器上做 git 写操作，否则提交与分支会互相错位。
- **cmux 升级**可能迁移 `cmux.json` 的 `schemaVersion`，也可能再次改动它读哪些配置路径。
  升级后跑一次 `./check.sh` 确认软链还在，并对照 `cmux config paths` 确认
  「Related (cmux's own Ghostty-format terminal config)」仍是 `~/.config/cmux/config.ghostty`。
