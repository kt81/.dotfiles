-- LSP, completion, and formatting (replaces ALE). mason installs servers into
-- nvim's own data dir, so no system packages are required.
return {
  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      { 'L3MON4D3/LuaSnip', dependencies = { 'saadparwaiz1/cmp_luasnip' } },
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        }),
      })
    end,
  },

  -- LSP servers via mason
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        -- Keep first-launch light. Add servers here (or via :Mason) as needed.
        ensure_installed = { 'lua_ls' },
      })

      -- nvim 0.11+ LSP API: nvim-lspconfig ships each server's defaults as
      -- lsp/<name>.lua, consumed by vim.lsp.config/enable (the old
      -- require('lspconfig')[server].setup framework is deprecated). The '*'
      -- entry layers our shared cmp capabilities onto every server.
      local caps = require('cmp_nvim_lsp').default_capabilities()
      vim.lsp.config('*', { capabilities = caps })
      vim.lsp.enable({ 'lua_ls' })

      -- Shared LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local function m(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          m('gd', vim.lsp.buf.definition, 'Go to definition')
          m('gr', vim.lsp.buf.references, 'References')
          m('K', vim.lsp.buf.hover, 'Hover')
          m('<leader>rn', vim.lsp.buf.rename, 'Rename')
          m('<leader>ca', vim.lsp.buf.code_action, 'Code action')
          m('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'Prev diagnostic')
          m(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'Next diagnostic')
        end,
      })
    end,
  },

  -- Formatting (replaces ALE fixers)
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    keys = {
      { '<leader>f', function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
        desc = 'Format buffer' },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        sh = { 'shfmt' },
      },
      format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
    },
  },
}
