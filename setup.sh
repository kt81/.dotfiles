#!/bin/sh
# setup.
[ ! -e ~/.zshrc ] && ln -s ~/.config/.zshrc ~/.zshrc
[ ! -e ~/.zshrc ] && ln -s ~/.config/.vimrc ~/.vimrc
touch ~/.zshrc.mine
