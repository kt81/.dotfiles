#!/bin/sh

# setup.
[ ! -e ~/.zshrc ] && ln -s ~/.common_conf/.zshrc ~/.zshrc
[ ! -e ~/.vimrc ] && ln -s ~/.common_conf/.vimrc ~/.vimrc
[ ! -e ~/.gvimrc ] && ln -s ~/.common_conf/.gvimrc ~/.gvimrc
[ ! -e ~/.vim ] && mkdir ~/.vim
[ ! -e ~/.config ] && mkdir ~/.config
[ ! -e ~/.config/nvim ] && mkdir ~/.config/nvim
[ ! -e ~/.config/nvim/init.vim ] && ln -s ~/.vimrc ~/.config/nvim/init.vim
[ ! -e ~/.tmux.conf ] && ln -s ~/.common_conf/.tmux.conf ~/.tmux.conf
