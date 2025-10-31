return {
  'floating-terminal', -- virtual plugin name
  dir = vim.fn.stdpath 'config',
  lazy = false, -- load on startup
  config = function()
    local state = {
      floating = {
        buf = -1,
        win = -1,
      },
    }

    local function OpenFloatingTerminal(opts)
      opts = opts or {}
      local width_ratio = opts.width or 0.8
      local height_ratio = opts.height or 0.8

      local ui = vim.api.nvim_list_uis()[1]
      local width = math.floor(ui.width * width_ratio)
      local height = math.floor(ui.height * height_ratio)
      local col = math.floor((ui.width - width) / 2)
      local row = math.floor((ui.height - height) / 2)

      local buf
      if not vim.api.nvim_buf_is_valid(opts.buf) then
        buf = vim.api.nvim_create_buf(false, true)
      else
        buf = opts.buf
      end

      local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded',
      })

      return { buf = buf, win = win }
    end

    local function toggle_terminal()
      if not vim.api.nvim_win_is_valid(state.floating.win) then
        local result = OpenFloatingTerminal { buf = state.floating.buf }
        state.floating.buf = result.buf
        state.floating.win = result.win

        if vim.bo[state.floating.buf].buftype ~= 'terminal' then
          vim.fn.termopen(vim.o.shell)
        end

        vim.cmd 'startinsert'
      else
        vim.api.nvim_win_hide(state.floating.win)
      end
    end

    vim.api.nvim_create_user_command('Floaterminal', toggle_terminal, {})
    vim.keymap.set({ 'n', 't' }, '<space>tt', toggle_terminal, { noremap = true, silent = true, desc = 'Toggle floating terminal' })
  end,
}
