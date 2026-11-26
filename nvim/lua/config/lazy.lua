-- Bootstrap lazy.nvim (self-installs on first launch; no external installer).
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
  -- Pin lazy.nvim itself to lazy-lock.json. The startup auto-install checks out
  -- every *other* plugin at its locked commit, but lazy.nvim is already present
  -- (cloned above at `stable`), so it's skipped — and when that install finishes
  -- it rewrites the lockfile with whatever is on disk, clobbering the pin before
  -- `Lazy! restore` can read it. Checking out the locked commit here avoids that.
  local ok, lock = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath('config') .. '/lazy-lock.json'), '\n'))
  end)
  local commit = ok and lock['lazy.nvim'] and lock['lazy.nvim'].commit
  if commit then
    vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--quiet', commit })
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { { import = 'plugins' } },
  install = { colorscheme = { 'tokyonight' } },
  checker = { enabled = false },
  change_detection = { notify = false },
})
