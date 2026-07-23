#!/usr/bin/env bash

set -e

#
# For Mac and Linux
#

repoRoot=$(realpath "$(dirname "$0")")
source "${repoRoot}/lib/libxnix.sh"

# Linux (apt) package lists. macOS uses the declarative Brewfile (see below).
# PHP-from-source build deps were removed; generic build tools kept for asdf/mise.
packagesCommon=(
    # essentials
    zsh tmux neovim
    htop ripgrep
    curl wget file unzip gpg jq
    # VCS
    git git-lfs tig
    # generic build tools (asdf/mise source builds)
    coreutils automake autoconf openssl libtool gettext pkg-config
)

# ubuntu
packagesLinux=(
    fd-find apt-transport-https software-properties-common
    # runtime (ruby/python) source-build deps
    build-essential libssl-dev zlib1g-dev libyaml-dev libsqlite3-dev libreadline-dev
    # ICU runtime for the mise/aqua PowerShell tarball (.NET globalization).
    # Unlike the MS pwsh package, libicu ships in Ubuntu's own repos, so it
    # installs on 26.04 too. (-dev is the version-agnostic name; pulls libicuNN.)
    libicu-dev
)
# Linux CLI tools come from mise (prebuilt binaries) — no rust toolchain needed.
# rust/cargo is installed manually only on hosts where you actually build Rust.
miseTools=(
    eza delta bat zoxide starship atuin gh fzf
    tree-sitter         # CLI to build nvim-treesitter parsers (main branch needs it)
    "aqua:noborus/ov"   # ov — feature-rich pager; not in mise's shorthand registry
    # pwsh 7 — self-contained linux tarball from GitHub releases. Replaces the MS
    # apt repo, which has no powershell package for Ubuntu 26.04. Needs libicu
    # (see packagesLinux) for full .NET globalization.
    "aqua:PowerShell/PowerShell"
)

# ----------------------------------
# Check Environment ($machine)
# ----------------------------------

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac


# ----------------------------------
# Mac
# ----------------------------------

if [[ $machine = Mac ]] ; then

    # Homebrew
    if ! cex brew ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        export PATH="/opt/homebrew/bin:$PATH"
    fi

    # Homebrew packages (declarative — see Brewfile / Brewfile.local)
    brew bundle --file="${repoRoot}/Brewfile"
    [ -f "${repoRoot}/Brewfile.local" ] && brew bundle --file="${repoRoot}/Brewfile.local"

    # Screenshot behaviour
    defaults write com.apple.screencapture type jpg
    defaults write com.apple.screencapture disable-shadow -bool true
    killall SystemUIServer
fi

# ----------------------------------
# Linux
# ----------------------------------

if [[ $machine = 'Linux' ]] ; then
    read -p "Install system packages? Enter N to skip if you're on a shared server. (y/N): " -n 1 -r inst
    echo
    if [[ $inst =~ ^[Yy]$ ]] ; then
        sudo apt-get update
        sudo apt-get install -y "${packagesCommon[@]}" "${packagesLinux[@]}"

        # Generate en_US.UTF-8 so LC_ALL='en_US.UTF-8' works without warnings
        if ! locale -a 2>/dev/null | grep -qix 'en_US.utf-\?8' ; then
            sudo apt-get install -y locales
            sudo locale-gen en_US.UTF-8
        fi
    fi
    # PowerShell (pwsh) is no longer installed from the Microsoft apt repo — it
    # has no package for Ubuntu 26.04. It now comes from mise/aqua (see miseTools
    # / the `mise use` calls below), which works on every Ubuntu version.

    # CLI tools via mise (prebuilt binaries; no rust build). Install mise first.
    if ! cex mise ; then
        curl https://mise.run | sh
    fi
    "$HOME/.local/bin/mise" use -g "${miseTools[@]}"
    "$HOME/.local/bin/mise" install

    # ----------------------------------
    # WSL-specific setup
    # ----------------------------------
    if [[ -n "$WSL_DISTRO_NAME" ]] ; then
        # wslu provides wslview (open files/URLs with the Windows default app)
        if ! cex wslview ; then
            sudo apt-get install -y wslu || true
        fi
        # Don't import the huge Windows PATH -- keeps command lookup / completion
        # fast. zshrc.wsl.zsh re-adds the few Windows tools we call. Needs a
        # one-time `wsl --shutdown` from Windows to take effect.
        if ! grep -q 'appendWindowsPath' /etc/wsl.conf 2>/dev/null ; then
            printf '\n[interop]\nappendWindowsPath = false\n' | sudo tee -a /etc/wsl.conf >/dev/null
            echo ">> /etc/wsl.conf updated: run 'wsl --shutdown' from Windows to apply."
        fi
    fi
fi

# ----------------------------------
# ZSH
# ----------------------------------
# ~/.zshrc is a LOCAL file (a copy, not a symlink) so that tool installers and
# machine-specific tweaks land there instead of dirtying this repo. It just
# sources the tracked core config. Only seed it once; never clobber a local one.
[ -e ~/.zshrc ] || cp "$repoRoot/zshrc.template" ~/.zshrc
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -e $ZINIT_HOME ]] ; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

sudo chsh -s "$(which zsh)" "$USER" 

# ----------------------------------
# Common and PowerShell
# ----------------------------------
# pwsh isn't on PATH in this bash context on Linux (mise isn't activated here),
# so resolve it via mise; on macOS it's on PATH already. GLOBALIZATION_INVARIANT
# lets the tarball pwsh run even when libicu is missing (e.g. system packages
# were skipped) — safe here since this is a -NoProfile config run doing no
# culture-sensitive work; interactive pwsh gets real ICU from libicu.
pwshBin="$(command -v pwsh || "$HOME/.local/bin/mise" which pwsh 2>/dev/null)"
[ -n "$pwshBin" ] && DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 "$pwshBin" -NoProfile "$repoRoot/setup.core.ps1"

# ----------------------------------
# Common over *NIX Platforms
# ----------------------------------
# (fzf comes from mise on Linux and the Brewfile on macOS; shell keybindings are
# wired up via `fzf --zsh` in zshrc.core.zsh — no git-install needed.)

if [ ! -d ~/.tmux/plugins/tpm ] ; then
    mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    pushd ~/.tmux/plugins/tpm/
    git fetch --all --prune
    git reset --hard origin/HEAD
    popd
fi

# git: make the local ~/.gitconfig include the managed config (declarative).
# Personal identity / credentials and any `git config --global` writes stay local.
# Append the [include] if missing (creating the file if needed); appended last so
# the managed settings win over any legacy local duplicates.
incPath="$repoRoot/gitconfig"
if ! grep -qF "$incPath" ~/.gitconfig 2>/dev/null ; then
    printf '\n[include]\n\tpath = %s\n' "$incPath" >> ~/.gitconfig
fi

zsh

# vim: et:ts=4:sw=4:ft=bash
