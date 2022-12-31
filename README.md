.dotfiles
=======

Overview
--------

This repository is intended to be a starter kit to setup development environment.

Target environment:

- Windows (10 / 11)
- macOS (Big Sur / Monterey)
- Linux (Ubuntu 22.04 with WSL / Other debian family systems (not tested))

Will do:

- Install 3rd party package manager (Homebrew for mac / Chocolatey for windows)
- Install newer version of PowerShell (pwsh) on ANY SYSTEM
- Install tools and libraries (see `setup.*`)
- Install oh-my-posh and PowerLevel10k as prompt
- Create symbolic links for dotfiles

Including:

- Nice shell prompt
- IDE-like neovim
- powerline-like tmux theme
- Build tools
- asdf
- cargo
- powershell
- Some other nice tools

Usage
------

### Windows

On elevated `powershell.exe` (system default version)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kt81/.dotfiles/HEAD/install.ps1'))
```

### Linux / macOS

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kt81/.dotfiles/HEAD/install.sh)"

# OR

cd ~
git clone https://github.com/kt81/.dotfiles.git
.dotfiles/setup.sh
```

Disclaimer
----------

The scripts in this repository install certain amount of packages on running system automatically and use `sudo` as needed.
If you want to customize and reuse this repo, please make sure that you understand what the scripts will do.
