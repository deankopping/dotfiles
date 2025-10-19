local ascii_art = {
  [[                                                                       ]],
  [[                                                                     ]],
  [[       ████ ██████           █████      ██                     ]],
  [[      ███████████             █████                             ]],
  [[      █████████ ███████████████████ ███   ███████████   ]],
  [[     █████████  ███    █████████████ █████ ██████████████   ]],
  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
  [[                                                                       ]],
}
local header_width = 0
for _, line in ipairs(ascii_art) do
  local w = vim.api.nvim_strwidth(line)
  if w > header_width then
    header_width = w
  end
end

return {
  {
    'goolord/alpha-nvim',
    opts = function()
      local startify = require 'alpha.themes.startify'

      startify.section.header.val = ascii_art

      startify.config.opts.margin = math.floor((vim.api.nvim_win_get_width(0) - header_width) / 2)
      return startify.config
    end,
    config = function(_, opts)
      require('alpha').setup(opts)
    end,
  },
}
