-- Neovim entry point (tracked by dotfiles; the whole nvim/ dir is symlinked to
-- the OS config location). Lua + lazy.nvim; the old vim-plug/.vimrc is retired.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.lazy')
