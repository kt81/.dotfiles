#!/bin/sh
# setup.
[ ! -e ~/.zshrc ] && ln -s ~/.config/.zshrc ~/.zshrc
[ ! -e ~/.vimrc ] && ln -s ~/.config/.vimrc ~/.vimrc
touch ~/.zshrc.mine
