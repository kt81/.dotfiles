-- Non-plugin keymaps. Plugin-specific maps live with their plugin specs.
local map = vim.keymap.set

-- Move by display line (kept from the old .vimrc)
map({ 'n', 'x' }, 'j', 'gj')
map({ 'n', 'x' }, 'k', 'gk')
map({ 'n', 'x' }, '<Down>', 'gj')
map({ 'n', 'x' }, '<Up>', 'gk')

-- Clear search highlight
map('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Window navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
