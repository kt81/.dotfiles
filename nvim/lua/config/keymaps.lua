-- Non-plugin keymaps. Plugin-specific maps live with their plugin specs.
local map = vim.keymap.set

-- Move by display line (kept from the old .vimrc)
map({ 'n', 'x' }, 'j', 'gj')
map({ 'n', 'x' }, 'k', 'gk')
map({ 'n', 'x' }, '<Down>', 'gj')
map({ 'n', 'x' }, '<Up>', 'gk')

-- Clear search highlight
map('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Window navigation lives with the vim-tmux-navigator spec in plugins/editor.lua:
-- C-h/j/k/l has to fall through to the neighbouring tmux pane once there is no
-- split left in that direction, which plain <C-w>h cannot do.
