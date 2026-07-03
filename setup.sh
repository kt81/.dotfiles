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
    git git-lfs
    # generic build tools (asdf/mise source builds)
    coreutils automake autoconf openssl libtool gettext pkg-config
)

# ubuntu
packagesLinux=(
    fd-find apt-transport-https software-properties-common
    # runtime (ruby/python) source-build deps
    build-essential libssl-dev zlib1g-dev libyaml-dev libsqlite3-dev libreadline-dev
)
packagesLinuxCargo=(
    eza git-delta bat zoxide
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
    read -p "Are you sure you want to install System Packages? Please input N to skip if you are on SHARED SERVER. (y/N): " -n 1 -r inst
    echo
    if [[ $inst =~ ^[Yy]$ ]] ; then
        source /etc/os-release
        sudo apt-get update
        sudo apt-get install -y "${packagesCommon[@]}" "${packagesLinux[@]}"

        if ! dpkg -s packages-microsoft-prod &>/dev/null ; then
            wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            sudo apt-get update
            sudo apt-get install -y powershell
            rm packages-microsoft-prod.deb
        fi
    fi

    if ! cex cargo ; then
        if [[ -e $HOME/.cargo/env ]] ; then
            source "$HOME/.cargo/env"
        else
            curl https://sh.rustup.rs -sSf | sh -s -- -y
        fi
    fi
    ~/.cargo/bin/rustup update
    ~/.cargo/bin/cargo install "${packagesLinuxCargo[@]}"
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
cex pwsh && pwsh -NoProfile "$repoRoot/setup.core.ps1"

# ----------------------------------
# Common over *NIX Platforms
# ----------------------------------
# fzf: macOS gets it from the Brewfile; other platforms fall back to git-install
# (with keybindings/completion enabled).
if [ "$machine" != Mac ] && [ ! -e ~/.fzf ] ; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
fi

if [ ! -d ~/.tmux/plugins/tpm ] ; then
    mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    pushd ~/.tmux/plugins/tpm/
    git fetch --all --prune
    git reset --hard origin/HEAD
    popd
fi

# git: seed a local ~/.gitconfig that includes the managed config (declarative).
# Personal identity / credentials and any `git config --global` writes stay local.
if [ ! -e ~/.gitconfig ] ; then
    printf '[include]\n\tpath = %s/gitconfig\n' "$repoRoot" > ~/.gitconfig
fi

zsh

# vim: et:ts=4:sw=4:ft=bash
