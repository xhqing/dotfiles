# dotfiles · 项目硬约束

身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 这是什么

身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 核心机制（不要改设计）

身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。
2. **映射表是唯一登记处**：`mappings.conf` 每行「仓库内路径 <TAB> 系统路径 <TAB> 权限或 `-` <TAB> 说明」，`install.sh` 与 `check.sh` 都读它。新增 App 只改这里，不在脚本里写死路径。
身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 新增一个 App 的固定六步

1. 建目录（简称、全小写）；
2. 配置放进去；
3. `mappings.conf` 加一行；
4. 目录里写 `README.md`：这份配置是什么、谁在读、**有没有别的 App 也读它**；
5. 若确有多个 App 共用同一份文件，同步更新根 `README.md` 的「共用配置文件」表；
6. `./install.sh` → `./check.sh` 全绿 → 提交。

## 共用配置文件（必须显式注明）

- 目前**唯一**的跨 App 共用项是 `ghostty/config`：Ghostty 与 cmux 都读（cmux 基于 libghostty，读同一份配置）。
- `cmux/config.ghostty` 虽是 Ghostty 语法，但**只有 cmux 读**——「Ghostty 格式」不等于「Ghostty 会用」。
- 改动共用关系时，根 README 的表与相关目录 README 必须同批更新，否则下一个人会在错误的地方改配置。

## 不许破坏的既有行为

1. `ghostty/config` 里 `font-family = Menlo` 之后**必须保留** `font-family = PingFang SC`——cmux 在没有多字体族回退链时会把中文钉到 `PingFang SC Regular`，细一档，中文观感明显变差。
2. `cmux.json` 权限保持 `600`；`install.sh` 按 `mappings.conf` 的权限列设置，不要把手动 `chmod` 当常态化做法。
身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 敏感信息（本仓库为公开仓库）

- **不备份、不提交**：登录凭证、keychain token、遥测 / 安装 ID、会话与工作区快照、滚动历史、agent journal、浏览器历史、窗口位置。
- `cmux/cmux.json` 可能出现控制 socket 的密码配置，**只能写占位符**，真实值留在本机、不进仓库。
- 往仓库新增任何 App 配置前先自问一句「这份文件里有没有凭证 / 本机私有标识」，有就先脱敏。

## 验证方式

```bash
身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。
```

身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 发布

配置仓库，**不 bump、不发 Release**；`VERSION` 只作记录。
