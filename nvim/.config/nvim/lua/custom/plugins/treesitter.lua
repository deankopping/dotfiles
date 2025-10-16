return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- `run` → renamed to `build` in Lazy
    opts = {
      ensure_installed = { 'typescript', 'tsx', 'python' },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      modules = {},

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },

  -- 🌲 Sticky Scroll
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPre',
    config = function()
      require('treesitter-context').setup {
        enable = true, -- Enable by default
        max_lines = 1, -- How many lines of context to show
        trim_scope = 'outer', -- When context is too large, trim outer blocks
        mode = 'topline', -- Use cursor position (alternative: 'topline')
      }
    end,
  },
}
