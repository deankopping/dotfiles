return {
  {
    'tpope/vim-fugitive',
    config = function()
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      ------------------------------------------------------------------------------
      -- Fugitive core commands
      ------------------------------------------------------------------------------

      -- Main git status UI (like lazygit inside vim)
      map('n', '<Leader>gg', ':Git<CR>', opts)

      -- Raw git status output
      map('n', '<Leader>gS', ':Git status<CR>', opts)

      -- Commit window (opens commit buffer and enters insert mode)
      map('n', '<Leader>gc', ':Git commit | startinsert<CR>', opts)

      ------------------------------------------------------------------------------
      -- Diff, merge, split tools
      ------------------------------------------------------------------------------

      map('n', '<Leader>gd', ':Git difftool<CR>', opts)
      map('n', '<Leader>gm', ':Git mergetool<CR>', opts)
      map('n', '<Leader>gv', ':Gvdiffsplit<CR>', opts)
      map('n', '<Leader>g_', ':Gdiffsplit<CR>', opts)
    end,
  },
}
