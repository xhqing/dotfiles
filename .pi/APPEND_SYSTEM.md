# dotfiles · 项目专属硬规则

本文件由 pi 在 cwd 位于本仓库（或其 worktree）时自动追加进系统提示。**只写本项目特有的约定**；全局规则与 Kit 的身份来自仓库根的 `AGENTS.md`，这里不复述、也不覆盖。

## 这是什么

按 App 分类的个人配置文件仓库：配置的**实体只存仓库一份**，系统位置靠软链指过来，换新机器 clone 后跑一次 `./install.sh` 就恢复成同一套习惯。目前收录 Ghostty 与 cmux。

## 核心机制（不要改设计）

1. **物理文件只存一份 + 软链**，不做复制。理由：改一处两边同步，不会出现「仓库里是旧版本」的漂移。
2. **映射表是唯一登记处**：`mappings.conf` 每行「仓库内路径 <TAB> 系统路径 <TAB> 权限或 `-` <TAB> 说明」，`install.sh` 与 `check.sh` 都读它。新增 App 只改这里，不在脚本里写死路径。
3. **`install.sh` 必须保持幂等且不丢数据**：目标已存在且不是软链时，先改名成 `xxx.bak.<时间戳>` 再建链——这条行为不能去掉。

## 新增一个 App 的固定六步

1. 建目录（简称、全小写）；
2. 配置放进去；
3. `mappings.conf` 加一行；
4. 目录里写 `README.md`：这份配置是什么、谁在读、**有没有别的 App 也读它**；
5. 若确有多个 App 共用同一份文件，同步更新根 `README.md` 的「配置文件归属」表；
6. `./install.sh` → `./check.sh` 全绿 → 提交。

## 配置文件归属（必须显式注明）

- **当前没有跨 App 共用的配置文件**：`ghostty/config` 只有 Ghostty 读，cmux 自 v0.65.2.2-r21 起只读自己的 `~/.config/cmux/config.ghostty`（上游 Issue #70 把两者解耦）。
- `cmux/config.ghostty` 虽是 Ghostty 语法，但**只有 cmux 读**——「Ghostty 格式」不等于「Ghostty 会用」。
- 两边外观各自维护：主题、字体族、字号、光标这类共同项要在两份文件里**各写一次**，只改一份只有那一个终端变。
- 归属关系变化时，根 README 的表与相关目录 README 必须同批更新，否则下一个人会在错误的地方改配置。
- 文档或注释里出现「cmux 读 `~/.config/ghostty/config`」「`~/Library/Application Support/com.cmuxterm.app/config.ghostty`」即属过时口径，发现就改掉。

## 不许破坏的既有行为

1. `ghostty/config` 与 `cmux/config.ghostty` 里 `font-family = Menlo` 之后**都必须保留** `font-family = PingFang SC`——没有显式多字体族回退链时，cmux 会把中文钉到 `PingFang SC Regular`，细一档，中文观感明显变差。
2. `cmux.json` 权限保持 `600`；`install.sh` 按 `mappings.conf` 的权限列设置，不要把手动 `chmod` 当常态化做法。
3. `cmux/defaults.plist` 只备份白名单项，安装时整份写回，不建软链。

## 敏感信息（本仓库为公开仓库）

- **不备份、不提交**：登录凭证、keychain token、遥测 / 安装 ID、会话与工作区快照、滚动历史、agent journal、浏览器历史、窗口位置。
- `cmux/cmux.json` 可能出现控制 socket 的密码配置，**只能写占位符**，真实值留在本机、不进仓库。
- 往仓库新增任何 App 配置前先自问一句「这份文件里有没有凭证 / 本机私有标识」，有就先脱敏。

## 验证方式

```bash
./check.sh    # 软链指向、UserDefaults 快照、仓库是否干净
```

三处全绿才算改完。若报「不是软链」，说明目标被某个程序的原子写替换成了普通文件——跑一次 `./install.sh` 修好，别手工 `ln`。

涉及终端配置改动时，额外核对 cmux 实际读的路径是否仍是 `~/.config/cmux/config.ghostty`：
`cmux config paths | grep -A1 "Related"`（CLI 在 `/Applications/cmux.app/Contents/MacOS/cmux`）。

## 发布

配置仓库，**不 bump、不发 Release**；`VERSION` 只作记录。
