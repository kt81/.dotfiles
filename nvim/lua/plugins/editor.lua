-- Fuzzy finding, syntax, git, and editing helpers.
return {
  -- Fuzzy finder (replaces fzf.vim). No native build step, so it works on a
  -- fresh Windows box without a C toolchain; uses ripgrep/fd for grep+files.
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>',  desc = 'Live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',    desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>',  desc = 'Help' },
      { '<C-p>',      '<cmd>Telescope find_files<cr>', desc = 'Find files' },
    },
    opts = {},
  },

  -- Treesitter highlighting + indentation.
  -- On the `main` branch: a full, incompatible rewrite of nvim-treesitter that
  -- requires nvim 0.11+ (we're on 0.12). It drops the old `master` API entirely
  -- — no `configs.setup`, no `ensure_installed`, no highlight/indent modules.
  -- Instead: install parsers with `install()`, and turn highlighting on per
  -- buffer with `vim.treesitter.start()` (see the FileType autocmd below).
  -- Parsers compile on install, so a C compiler (clang/LLVM, gcc, ...) must be
  -- on PATH. `master` is frozen upstream; `main` is the maintained branch.
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    -- Not lazy: highlighting is wired through a FileType autocmd, which must be
    -- registered before the first buffer's FileType fires.
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')
      ts.setup() -- defaults are fine (install_dir = stdpath('data')/site)

      local ensure = {
        'lua', 'vim', 'vimdoc', 'bash', 'json', 'yaml', 'toml',
        'markdown', 'markdown_inline', 'c_sharp', 'python', 'go',
        'javascript', 'typescript', 'html', 'css',
      }
      -- Install (async) any wanted parser we don't already have. No-op once the
      -- set is present, so this is cheap on every subsequent launch.
      local installed = ts.get_installed()
      local missing = vim.tbl_filter(function(l)
        return not vim.tbl_contains(installed, l)
      end, ensure)
      if #missing > 0 then ts.install(missing) end

      -- Enable highlight + treesitter indentation per buffer. If a filetype's
      -- parser is missing but installable, kick off an async install (the old
      -- `auto_install = true`) — it takes effect next time that filetype opens.
      local available = ts.get_available()
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('dotfiles_treesitter', { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if not lang then return end
          local ok, added = pcall(vim.treesitter.language.add, lang)
          if ok and added then
            vim.treesitter.start(ev.buf, lang)
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          elseif vim.tbl_contains(available, lang) then
            ts.install({ lang })
          end
        end,
      })
    end,
  },

  -- Git: sign column (replaces vim-signify) + fugitive
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
  { 'tpope/vim-fugitive', cmd = { 'Git', 'G' } },

  -- Editing: surround, align, autopairs, comments
  { 'kylechui/nvim-surround', event = 'VeryLazy', opts = {} },
  {
    'echasnovski/mini.align',
    keys = {
      { 'ga', mode = { 'n', 'x' }, desc = 'Align' },
      { 'gA', mode = { 'n', 'x' }, desc = 'Align with preview' },
    },
    opts = {},
  },
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  { 'numToStr/Comment.nvim', event = 'VeryLazy', opts = {} },
}
