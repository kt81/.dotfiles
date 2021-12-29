#!/usr/bin/env bash

set -e

#
# For Mac and Linux
#

repoRoot=$(realpath $(dirname "$0"))

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
    fd exa
    coreutils libyaml readline libxslt libtool unixodbc gd
    libjpeg mysql-connector-c oniguruma
)
# ubuntu
packagesLinux=(
    fd-find apt-transport-https software-properties-common
    build-essential libyaml-dev libxslt-dev libgd-dev libcurl4-openssl-dev libedit-dev libicu-dev 
    libjpeg-dev libmysqlclient-dev libonig-dev libpng-dev libpq-dev libsqlite3-dev libssl-dev libxml2-dev libzip-dev zlib1g-dev
)

# Shorthand
cex() {
    command -v $1 >/dev/null 2>&1;
}

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

if [ $machine = Mac ] ; then

    # Homebrew
    if ! cex brew ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    # Homebrew Packages
    brew install ${packagesCommon[@]} ${packagesMac[@]}

    # anyenv
    if [ ! command -v anyenv > /dev/null 2>&1 ] ; then
        brew install anyenv
        anyenv init
        eval "$(anyenv init -)"
        anyenv install --init
    fi

    # powerline
    pip3 install --user powerline-status

    # Screenshot behaviour
    defaults write com.apple.screencapture type jpg
    defaults write com.apple.screencapture disable-shadow -bool true
    killall SystemUIServer
fi

# ----------------------------------
# Linux
# ----------------------------------

if [ $machine = 'Linux' ] ; then
    read -p "Are you sure you want to install System Packages? Please input N to skip if you are on SHARED SERVER. (y/N): " -n 1 -r inst
    echo
    if [[ $inst =~ ^[Yy]$ ]] ; then
        sudo apt update
        sudo apt install -y ${packagesCommon[@]} ${packagesLinux[@]}

        wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt update
        sudo add-apt-repository universe
        sudo apt install -y powershell
        rm packages-microsoft-prod.deb
    fi

    if ! cex cargo ; then
        if [ -e ~/.cargo/env ] ; then
            source ~/.cargo/env
        else
            curl https://sh.rustup.rs -sSf | sh -s -- -y
        fi
    fi
    if ! cex exa ; then
        cargo install exa
    fi
fi

# ----------------------------------
# ZSH
# ----------------------------------
[ -e ~/.zshrc ] || ln -s $repoRoot/.zshrc ~/.zshrc
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -e $ZEINIT_HOME ]] ; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

sudo chsh $USER -s $(which zsh)

# ----------------------------------
# Common and PowerShell
# ----------------------------------
cex pwsh && pwsh -NoProfile $repoRoot/setup.core.ps1

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

sh $repoRoot/git.sh
sudo chsh $USER -s $(which zsh)
zsh

# vim: et:ts=4:sw=4:ft=bash
