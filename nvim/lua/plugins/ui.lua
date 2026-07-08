-- Statusline, file tree, and icons.
return {
  -- Nerd Font icons (HackGen NF provides the glyphs)
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Statusline (replaces vim-airline)
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        theme = 'tokyonight',
        globalstatus = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
    },
  },

  -- File explorer (replaces fern). <leader>e toggles; opens on `nvim <dir>`.
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle reveal<cr>', desc = 'Explorer' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true },
      },
    },
    init = function()
      -- Open the tree when nvim is started on a directory.
      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('NeoTreeOnDir', { clear = true }),
        callback = function()
          local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
          if stats and stats.type == 'directory' then
            require('neo-tree')
            vim.cmd('Neotree reveal')
          end
        end,
      })
    end,
  },
}
