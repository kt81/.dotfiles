-- General editor options (ports the non-plugin parts of the old .vimrc).
local opt = vim.opt

opt.number = true
opt.ruler = true
opt.laststatus = 3            -- global statusline (lualine)
opt.confirm = true
opt.mouse = 'a'
opt.termguicolors = true
opt.signcolumn = 'yes'        -- stable gutter (gitsigns/diagnostics)
opt.scrolloff = 4
opt.splitright = true
opt.splitbelow = true

-- search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- indent (4-space, expandtab — as in the old config)
opt.autoindent = true
opt.expandtab = true
opt.smarttab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.wrap = true

-- editing niceties
opt.backspace = { 'indent', 'eol', 'start' }
opt.clipboard = 'unnamedplus'
opt.undofile = true           -- persistent undo (upgrade over the old `nobackup`)
opt.backup = false
opt.showmatch = true

-- whitespace rendering (matches the old listchars)
opt.list = true
opt.listchars = { eol = '↲', trail = '-', tab = '» ', extends = '$', space = '.' }

-- Yank to the Windows clipboard from WSL (replaces the old clip.exe autocmd).
if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = { ['+'] = 'clip.exe', ['*'] = 'clip.exe' },
    paste = {
      ['+'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r",""))',
      ['*'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r",""))',
    },
    cache_enabled = 0,
  }
end
