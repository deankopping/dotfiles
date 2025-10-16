return { -- ~/.config/nvim/lua/custom/plugins/init.lua
  -- other plugins...
  { 'tpope/vim-fugitive' },
  { 'rebelot/kanagawa.nvim' },
  require 'custom.plugins.minimap',
  require 'custom.plugins.oil',
  require 'custom.plugins.alpha',
  require 'custom.plugins.treesitter',
  require 'custom.plugins.typescript-tools',
}
