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

-- Reserve space for "[10] " (5 chars) + icon (2 chars) + small buffer
local max_path_width = header_width - 8

--- Truncate string to at most max_w display width (safe for UTF-8).
local function truncate_str(s, max_w)
  if vim.api.nvim_strwidth(s) <= max_w then
    return s
  end
  local result = ''
  local len = vim.fn.strcharlen(s)
  for i = 0, len - 1 do
    local c = vim.fn.strcharpart(s, i, 1)
    if vim.api.nvim_strwidth(result .. c) > max_w - 1 then
      return result .. '…'
    end
    result = result .. c
  end
  return result
end

--- Abbreviate path so it fits within max_width display columns.
--- Prefers full path, then "…/filename", then truncated filename.
local function abbreviate_path(path, max_w)
  if vim.api.nvim_strwidth(path) <= max_w then
    return path
  end
  local tail = vim.fn.fnamemodify(path, ':t')
  local with_prefix = '…/' .. tail
  if vim.api.nvim_strwidth(with_prefix) <= max_w then
    return with_prefix
  end
  return truncate_str(tail, max_w)
end

return {
  {
    'goolord/alpha-nvim',
    opts = function()
      local startify = require 'alpha.themes.startify'

      startify.section.header.val = ascii_art

      -- Shorten file paths so MRU list doesn't extend past the ASCII header.
      -- We can't just override startify.file_button: mru() calls the local
      -- file_button inside the theme, so we must override the section val
      -- to use our own mru that passes abbreviated paths.
      local orig_mru = startify.mru
      local function abbreviated_mru(start_num, cwd, items_number, opts)
        local list = orig_mru(start_num, cwd, items_number, opts)
        for _, item in ipairs(list.val) do
          if item.type == 'button' and item.val then
            -- Val is "icon space path"; path starts after first space
            local prefix = item.val:match '^(.-%s+)' or ''
            local path = item.val:match '^.-%s+(.*)$' or item.val
            item.val = prefix .. abbreviate_path(path, max_path_width)
          end
        end
        return list
      end

      -- Replace the MRU section builders to use abbreviated paths
      startify.section.mru.val[4].val = function()
        return { abbreviated_mru(10) }
      end
      startify.section.mru_cwd.val[4].val = function()
        return { abbreviated_mru(0, vim.fn.getcwd()) }
      end

      startify.config.opts.margin = math.floor((vim.api.nvim_win_get_width(0) - header_width) / 2)
      return startify.config
    end,
    config = function(_, opts)
      require('alpha').setup(opts)
    end,
  },
}
