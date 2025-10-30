return {
  'gbprod/yanky.nvim',
  opts = {
    highlight = {
      timer = 250,
    },
  },
  config = function(_, opts)
    require('yanky').setup(opts)

    vim.api.nvim_set_hl(0, 'YankyYanked', {
      bg = '#6B5B95',
      fg = '#FFE3FF',
      bold = true,
    })

    vim.api.nvim_set_hl(0, 'YankyPut', {
      bg = '#FFAA5C',
      fg = '#FFF8E7',
      italic = true,
      bold = true,
    })
  end,
}
