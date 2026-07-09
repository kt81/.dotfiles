.dotfiles
=========

Overview
--------

A starting point for setting up a development host (macOS / Windows / Linux)
with my preferred tools and configuration.

### Target environment

- macOS (Apple Silicon)
- Windows (10 / 11)
- Linux (Ubuntu, including WSL; other Debian-family distros untested)

### What it does

- Installs packages, declaratively where possible:
  - macOS: Homebrew + a `Brewfile` (`brew bundle`); `Brewfile.local` for machine-specific extras
  - Windows: **winget** only, from a declarative `windows/winget.json`
    (`winget import`). Chocolatey has been retired.
  - Linux: apt for system packages + **mise** for CLI tools (eza, bat, delta,
    zoxide, starship, atuin, gh, fzf) as prebuilt binaries — no rust toolchain
    required (install rust/cargo manually only where you build Rust)
- Prompt is **[starship](https://starship.rs/)** everywhere — zsh *and* PowerShell
  share the one `starship.toml`
- Sets up **zsh** via [zinit](https://github.com/zdharma-continuum/zinit); the
  PowerShell profile mirrors it (starship + zoxide + atuin + mise + PSReadLine
  predictions)
- Installs **[mise](https://mise.jdx.dev/)** to manage language runtimes
  (node / python / ruby / …), honoring per-project `.tool-versions` / `.node-version`.
  Extra tracked tools (e.g. **keifu**) live in `mise/config.toml`, linked into
  mise's `conf.d` so `mise use -g` never dirties this repo.
- Symlinks editor, tmux, Neovim, mise and (on Windows) the Windows Terminal
  settings, and seeds a **local** `~/.zshrc` and `~/.gitconfig` that *source* /
  *include* the tracked configs — so tool installers and `git config --global`
  never dirty this repo
- Installs fzf, tmux plugins (tpm) and the HackGen Nerd Font

### Included

- **starship** prompt (cross-shell: zsh + PowerShell)
- **mise** for runtimes (replaces asdf + nvm)
- Modern CLI: eza, bat, fd, ripgrep, zoxide, git-delta, fzf, atuin, jq, bottom
- **[keifu](https://github.com/trasta298/keifu)** — colorful git commit-graph TUI
  (installed via mise); `tig` for log browsing on macOS / Linux / WSL
- **neovim** as a Lua + [lazy.nvim](https://github.com/folke/lazy.nvim) config
  (tokyonight, treesitter, telescope, neo-tree, lualine, gitsigns, fugitive,
  LSP via mason) — the old vim-plug / `.vimrc` is retired
- Powerline-style **tmux** theme
- zsh niceties: autosuggestions, fast-syntax-highlighting, extra completions
- A PowerShell profile mirroring the zsh setup, and a managed Windows Terminal
  config (HackGen Nerd Font + tokyonight-moon)

Layout
------

| File | Purpose |
|------|---------|
| `zshrc.core.zsh` | Tracked zsh config (sourced by the local `~/.zshrc`) |
| `zshrc.template` | Seed for the local `~/.zshrc` |
| `Microsoft.PowerShell_profile.ps1` | PowerShell profile (symlinked into `$PROFILE`) |
| `gitconfig` | Tracked git config (included by the local `~/.gitconfig`) |
| `starship.toml` | Prompt config (shared by zsh + PowerShell) |
| `Brewfile` / `Brewfile.local` | macOS packages (tracked base / untracked machine extras) |
| `windows/winget.json` | Windows package set (`winget import`) |
| `windows/WindowsTerminal/settings.json` | Managed Windows Terminal settings |
| `nvim/` | Neovim config (Lua + lazy.nvim; dir symlinked into place) |
| `mise/config.toml` | Tracked mise tools (linked into mise `conf.d`) |
| `atuin/` | Tracked atuin config |
| `.tmux.conf` | tmux config |
| `install.ps1` / `install.sh` | One-line bootstrap (clone + run the installer) |
| `setup.sh` / `setup.ps1` / `setup.core.ps1` | Installers |

Usage
-----

### macOS / Linux

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kt81/.dotfiles/HEAD/install.sh)"
```

or

```bash
git clone https://github.com/kt81/.dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh
```

### Windows

Enable **Developer Mode** first (Settings → For developers) so symlinks work
without an elevated shell. Then, in `powershell.exe`:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kt81/.dotfiles/HEAD/install.ps1'))
```

`install.ps1` installs git via winget, clones the repo to `~/.dotfiles`, and runs
`setup.ps1`, which imports `windows/winget.json` and hands off to `setup.core.ps1`
for modules, fonts, and symlinks. winget self-elevates per package as needed, so
the shell itself need not be elevated.

Notes:

- `tig` is not packaged for winget; use it inside WSL (installed by `setup.sh`).
  On native Windows, **keifu** (installed via mise) covers colorful commit-graph
  browsing, and `git log` is paged through git-delta.
- Treesitter parsers don't auto-install on Windows (an upstream `nvim-treesitter`
  path bug). Install them on demand with `:TSInstall <lang>` — a C compiler such
  as LLVM/clang must be on `PATH`.
- **WSL**: `setup.sh` sets `appendWindowsPath = false` in `/etc/wsl.conf` so
  shells don't inherit the huge Windows `PATH` (command lookup / completion stay
  fast); only the handful of Windows tools actually used are re-added in
  `zshrc.wsl.zsh`. Clipboard routes through `win32yank` (zsh `pbcopy`/`pbpaste`,
  tmux-yank, Neovim), and `open` / `start` use `wslview` (from `wslu`). Run
  `wsl --shutdown` once from Windows after setup to apply the PATH change.

Disclaimer
----------

These scripts install packages and use `sudo` as needed. If you want to reuse this
repo, please make sure you understand what they do first.
