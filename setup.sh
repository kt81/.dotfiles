#!/bin/bash

# setup.
[ ! -e ~/.zshrc ] && ln -s ~/.common_conf/.zshrc ~/.zshrc
[ ! -e ~/.vimrc ] && ln -s ~/.common_conf/.vimrc ~/.vimrc
[ ! -e ~/.gvimrc ] && ln -s ~/.common_conf/.gvimrc ~/.gvimrc
[ ! -e ~/.vim ] && mkdir ~/.vim
[ ! -e ~/.config ] && mkdir ~/.config
[ ! -e ~/.config/nvim ] && mkdir ~/.config/nvim
[ ! -e ~/.config/nvim/init.vim ] && ln -s ~/.vimrc ~/.config/nvim/init.vim
[ ! -e ~/.tmux.conf ] && ln -s ~/.common_conf/.tmux.conf ~/.tmux.conf

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
    if [ ! command -v brew > /dev/null 2>&1 ] ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    # Homebrew Packages
    brew install \
        zsh tmux vim neovim \
        git git-lfs tig \
        htop glances \
        php python composer

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

# ----------------------------------
# dein
# ----------------------------------

if [ ! -e ~/.cache/dein ] ; then
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > ~/dein_installer.sh
    sh ~/dein_installer.sh ~/.cache/dein
    rm -f ~/dein_installer.sh
fi

echo "Please restart the shell to apply all changes."

# vim: et:ts=4:sw=4
