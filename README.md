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
  - Windows: winget + Chocolatey
  - Linux: apt + cargo
- Sets up **zsh** via [zinit](https://github.com/zdharma-continuum/zinit) with a
  **[starship](https://starship.rs/)** prompt (PowerShell keeps oh-my-posh)
- Installs **[mise](https://mise.jdx.dev/)** to manage language runtimes
  (node / python / ruby / …), honoring per-project `.tool-versions` / `.node-version`
- Symlinks editor & tmux configs, and seeds a **local** `~/.zshrc` and `~/.gitconfig`
  that *source* / *include* the tracked configs — so tool installers and
  `git config --global` never dirty this repo
- Installs fzf, tmux plugins (tpm) and a Nerd Font

### Included

- **starship** prompt (cross-shell)
- **mise** for runtimes (replaces asdf + nvm)
- Modern CLI: eza, bat, fd, ripgrep, zoxide, git-delta, fzf
- IDE-ish **neovim** (tokyonight, fern, fugitive, ALE, fzf, …)
- Powerline-style **tmux** theme
- zsh niceties: autosuggestions, fast-syntax-highlighting, extra completions
- cargo, and a PowerShell profile where pwsh is available

Layout
------

| File | Purpose |
|------|---------|
| `zshrc.core.zsh` | Tracked zsh config (sourced by the local `~/.zshrc`) |
| `zshrc.template` | Seed for the local `~/.zshrc` |
| `gitconfig` | Tracked git config (included by the local `~/.gitconfig`) |
| `starship.toml` | Prompt config |
| `Brewfile` / `Brewfile.local` | macOS packages (tracked base / untracked machine extras) |
| `.vimrc` | neovim config (symlinked to `init.vim`) |
| `.tmux.conf` | tmux config |
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

On an elevated `powershell.exe`:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kt81/.dotfiles/HEAD/install.ps1'))
```

Disclaimer
----------

These scripts install packages and use `sudo` as needed. If you want to reuse this
repo, please make sure you understand what they do first.
