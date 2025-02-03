#!/usr/bin/env bash

set -e

#
# For Mac and Linux
#

repoRoot=$(realpath "$(dirname "$0")")
source "${repoRoot}/lib/libxnix.sh"

packagesCommon=(
    # essentials
    zsh tmux neovim
    htop glances ripgrep 
    curl wget file unzip gpg jq
    # VCS
    git git-lfs tig subversion
    # For asdf (Build tools)
    coreutils automake autoconf openssl libtool unixodbc bison gettext openssl pkg-config re2c 
)

packagesMac=(
    fd eza
    coreutils libyaml readline libxslt libtool unixodbc gd
    libjpeg mysql-connector-c oniguruma
    font-hackgen font-hackgen-nerd powershell/tap/powershell
)
# ubuntu
packagesLinux=(
    fd-find apt-transport-https software-properties-common
    build-essential libyaml-dev libxslt-dev libgd-dev libcurl4-openssl-dev libedit-dev libicu-dev 
    libjpeg-dev libmysqlclient-dev libonig-dev libpng-dev libpq-dev libsqlite3-dev libssl-dev libxml2-dev libzip-dev zlib1g-dev
)
packagesLinuxCargo=(
    eza git-delta
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

    # Homebrew Packages
    brew install "${packagesCommon[@]}" "${packagesMac[@]}"

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
[ -e ~/.zshrc ] || ln -s "$repoRoot/.zshrc" ~/.zshrc
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
if [ ! -e ~/.fzf ] ; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

if ! command -v asdf > /dev/null 2>&1 ; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    cd ~/.asdf
    git checkout "$(git describe --abbrev=0 --tags)"
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

"$repoRoot/git.sh"
zsh

# vim: et:ts=4:sw=4:ft=bash
