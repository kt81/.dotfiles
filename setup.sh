#!/bin/sh
# setup.
[ ! -e ~/.zshrc ] && ln -s ~/.common_conf/.zshrc ~/.zshrc
[ ! -e ~/.vimrc ] && ln -s ~/.common_conf/.vimrc ~/.vimrc
touch ~/.zshrc.mine
