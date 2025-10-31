return {
  'NickvanDyke/opencode.nvim',
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for default `toggle()` implementation.
    { 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
    }

    -- Required for `opts.auto_reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ 'n', 'x' }, '<C-a>', function()
      require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'Ask opencode' })

    vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
      require('opencode').select()
    end, { desc = 'Execute opencode action…' })

    vim.keymap.set({ 'n', 'x' }, 'ga', function()
      require('opencode').prompt '@this'
    end, { desc = 'Add to opencode' })

    vim.keymap.set('n', '<C-.>', function()
      require('opencode').toggle()
    end, { desc = 'Toggle opencode' })

    -- Scroll opencode messages up half page
    vim.keymap.set('n', '<S-C-u>', function()
      require('opencode').command 'messages_half_page_up'
    end, { desc = 'opencode half page up' })

    -- Scroll opencode messages down half page
    vim.keymap.set('n', '<S-C-d>', function()
      require('opencode').command 'messages_half_page_down'
    end, { desc = 'opencode half page down' })

    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
    -- Alternative keymap for increment (if <C-a> is used for opencode)
    vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment', noremap = true })

    -- Alternative keymap for decrement (if <C-x> is used for opencode)
    vim.keymap.set('n', '_', '<C-x>', { desc = 'Decrement', noremap = true })

    vim.keymap.set('n', '<leader>oo', function()
      require('opencode').toggle()

      vim.defer_fn(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          if name:match 'opencode' then
            vim.api.nvim_set_current_win(win)
            vim.cmd 'startinsert'
            return
          end
        end
      end, 100)
    end, { desc = 'Open opencode and focus input' })
  end,
  vim.keymap.set('t', '<leader><Esc>', '<C-\\><C-n><C-w>t', { desc = 'Exit opencode terminal and return to top-left window' }),
}
