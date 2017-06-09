#!/bin/sh
# setup.
[ ! -e ~/.zshrc ] && ln -s ~/.common_conf/.zshrc ~/.zshrc
[ ! -e ~/.vimrc ] && ln -s ~/.common_conf/.vimrc ~/.vimrc
[ ! -e ~/.vimrc ] && ln -s ~/.common_conf/.gvimrc ~/.gvimrc
[ ! -e ~/.tmux.conf ] && ln -s ~/.common_conf/.tmux.conf ~/.tmux.conf
