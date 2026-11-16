<div align="center">
  <img src="assets/logo.svg" alt="dotfiles" width="640">

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE.md)
  [![Version](https://img.shields.io/badge/Version-0.2.0-blue)](CHANGELOG.md)
  [![Type](https://img.shields.io/badge/Type-Project-lightgrey)](#)

  [简体中文](README_cn.md)
</div>

# dotfiles — app configs, versioned and symlinked

> **This project was retired on 2026-11-16.** All of its content moved into the `apps/`
> directory of [agents-infra](https://github.com/xhqing/agents-infra) — ghostty and cmux are
> the terminals every agent session runs in, so their configs are infrastructure. This
> repository is kept as a historical archive and is no longer updated.

Every app config worth carrying to a new machine lives here in one git repository.
Clone it, run `./install.sh`, and the new machine picks up the same habits — no
clicking through settings all over again.

## Layout

```
dotfiles/
├── mappings.conf           # repo path → system path map (install / check share it; a new app only touches this)
├── ghostty/                # App: the Ghostty terminal
│   ├── README.md           #   this directory's config is read by Ghostty only, see below
│   └── config              #   → ~/.config/ghostty/config
├── cmux/                   # App: the cmux terminal
│   ├── README.md           #   ⚠️ since r21 cmux reads only its own terminal config, see below
│   ├── cmux.json           #   → ~/.config/cmux/cmux.json
│   ├── config.ghostty      #   → ~/.config/cmux/config.ghostty
│   └── defaults.plist      #   cmux UserDefaults snapshot (written back on install, not symlinked)
├── install.sh              # new-machine setup: symlink per the map + write back the snapshot + cmux reload-config
├── check.sh                # verify symlinks / snapshot / repo state
├── export-defaults.sh      # refresh the UserDefaults snapshot after changing settings
└── scripts/                # export / apply helpers behind that snapshot
```

## Who reads which file (important)

Each config exists once in the repository, inside its app's directory, and this table
records who reads it — **whenever that changes, update this table and the directory
README in the same change**.

| Repository file | System location | Read by | Notes |
|---|---|---|---|
| `ghostty/config` | `~/.config/ghostty/config` | **Ghostty only** | Terminal settings for Ghostty (theme, fonts, size, cursor, window geometry, Quick Terminal hotkey) |
| `cmux/config.ghostty` | `~/.config/cmux/config.ghostty` | **cmux only** | cmux's own terminal config in Ghostty syntax — "Ghostty format" does not mean "Ghostty reads it". Since cmux v0.65.2.2-r21 cmux no longer reads `ghostty/config`; this file alone drives its look |
| `cmux/cmux.json` | `~/.config/cmux/cmux.json` | **cmux only** | App-level settings; the settings UI reads and writes it |
| `cmux/defaults.plist` | the `com.cmuxterm.app` UserDefaults domain | **cmux only** | Preference snapshot, written back on install, not symlinked |

In one line: **no config file is shared between apps today.** cmux and Ghostty were
fully decoupled in cmux v0.65.2.2-r21 (upstream Issue #70), so a look shared by both
terminals has to be written twice, once per file.

## Restoring on a new machine

```bash
git clone git@github.com:xhqing/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh          # symlinks + UserDefaults write-back + cmux reload-config
```

Notes:

- `install.sh` renames any existing regular file at the target to `xxx.bak.<timestamp>` before creating the symlink, so nothing is lost.
- Ghostty does not need to be installed first: since v0.65.2.2-r21 cmux reads only its own `~/.config/cmux/config.ghostty` and no longer depends on `~/.config/ghostty/config`.
- If cmux is already running afterwards, run `cmux reload-config` once.

## Day-to-day maintenance

| What changed | How it gets into the repo |
|---|---|
| Ghostty terminal settings (font, theme, cursor…) | Edit `~/.config/ghostty/config` directly (it is the repo file) → `git commit` |
| cmux terminal settings (font, theme, cursor…) | Edit `~/.config/cmux/config.ghostty` directly (it is the repo file) → `cmux reload-config` → `git commit`. To keep both terminals identical, write the same value in both files |
| Terminal options touched in the cmux settings UI | They land in `~/.config/cmux/config.ghostty` (repo file) → visible in `git status` → `git commit` |
| Preferences in cmux.json / the UI | Run `./export-defaults.sh` → `git commit` |

When unsure, run `./check.sh`: it reports broken symlinks, a stale snapshot, and
uncommitted changes.

## Adding a new app

1. Create a directory named after the app (short, lowercase);
2. Drop the config files in;
3. Add a line to `mappings.conf`: `repo-relative path <TAB> system path <TAB> mode or - <TAB> note`;
4. Write a `README.md` in that directory: what the config is, who reads it, **and whether any other app reads it too**;
5. If several apps really do share one file, update the "Who reads which file" table above;
6. Run `./install.sh` to wire the symlinks, confirm `./check.sh` is all green, then commit.

## Why symlinks instead of copies

There is exactly one copy of each config, so editing it updates both sides and the
repo can never drift into "the old version".

cmux resolves symlinks before writing `cmux.json` (the source calls
`resolvingSymlinksInPath` before saving). `config.ghostty` is a symlink now as well;
should a future release switch to atomic writes (replacing the link with a regular
file), `./check.sh` reports "not a symlink" and one `./install.sh` fixes it.

## What is and isn't backed up

**Backed up (configuration)**: `ghostty/config`, `cmux/cmux.json`,
`cmux/config.ghostty`, and the whitelisted `cmux/defaults.plist` entries (appearance
mode, sidebar style, right panel mode, file explorer width, and so on).

**Deliberately excluded**: login credentials and keychain tokens, telemetry / install
IDs, session and workspace snapshots, scrollback, agent journals, browser history,
window positions, and configs of other tools (add a directory when needed).

## Known gotchas

- **Chinese text weight**: both `ghostty/config` and `cmux/config.ghostty` declare
  `font-family = Menlo` followed by `font-family = PingFang SC`; neither line may be
  removed. Without an explicit font-family fallback chain, cmux injects a CJK
  codepoint map that pins Chinese to `PingFang SC Regular` — one weight lighter than
  Ghostty. Declaring the chain suppresses the injection. See `ghostty/README.md` and
  `cmux/README.md`.
- **Permissions**: `cmux.json` may hold the control socket password, so it stays at 600.
- **Don't write from two machines at once**: run git write operations on one machine
  at a time, or commits and branches will drift apart.
- **cmux upgrades** may migrate the `cmux.json` `schemaVersion`, and may change which
  config paths cmux reads. After an upgrade, run `./check.sh` to confirm the symlinks
  are intact and `cmux config paths` — the line "Related (cmux's own Ghostty-format
  terminal config)" must still be `~/.config/cmux/config.ghostty`.

## License & Attribution

Copyright (c) 2026 xhqing and contributors. Released under the [MIT License](LICENSE.md).

Attribution: if you use or reference this project, please keep the copyright notice
and credit the source: [dotfiles](https://github.com/xhqing/dotfiles).
