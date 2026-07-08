-- tokyonight (moon), matching starship / atuin / Windows Terminal.
return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = { style = 'moon' },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight-moon')
    end,
  },
}
