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

  -- Treesitter (replaces vim-polyglot for highlighting/indent).
  -- Pinned to the stable `master` branch; `main` dropped the configs API.
  -- Parsers are compiled on install, so a C compiler (clang/LLVM, gcc, ...)
  -- must be on PATH.
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      ensure_installed = {
        'lua', 'vim', 'vimdoc', 'bash', 'json', 'yaml', 'toml',
        'markdown', 'markdown_inline', 'c_sharp', 'python', 'go',
        'javascript', 'typescript', 'html', 'css',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
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
