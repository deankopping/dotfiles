return {
  'xTacobaco/cursor-agent.nvim',

  config = function()
    local agent = require 'cursor-agent'

    -- Get text of the last visual selection in buffer (uses '< and '> marks).
    local function get_visual_selection_from_buf(bufnr)
      local start_pos = vim.fn.getpos "'<"
      local end_pos = vim.fn.getpos "'>"
      if not start_pos or not end_pos or start_pos[2] == 0 or end_pos[2] == 0 then
        return ''
      end
      local start_row, start_col = start_pos[2] - 1, start_pos[3] - 1
      local end_row, end_col = end_pos[2] - 1, end_pos[3]
      local ok, lines = pcall(vim.api.nvim_buf_get_text, bufnr, start_row, start_col, end_row, end_col, {})
      if not ok or not lines then
        return ''
      end
      return table.concat(lines, '\n')
    end

    -- Open agent with prompt (used for file ref and one-off asks). For very
    -- long text we use a temp file to avoid ARG_MAX.
    local MAX_PROMPT_ARG = 32000 -- safe under typical ARG_MAX
    local function open_agent_with(text)
      if not text or text == '' then
        agent.ask {}
        return
      end
      if #text <= MAX_PROMPT_ARG then
        agent.ask { prompt = text }
        return
      end
      local util = require 'cursor-agent.util'
      local tmp = util.write_tempfile(text, '.txt')
      agent.ask { file = tmp, title = 'Cursor Agent' }
    end

    -- Check if the plugin's terminal job is still running (without waiting).
    local function job_is_alive(job_id)
      if not job_id or job_id == 0 then
        return false
      end
      local ok, res = pcall(vim.fn.jobwait, { job_id }, 0)
      if not ok or type(res) ~= 'table' then
        return false
      end
      return res[1] == -1 -- -1 means still running when timeout=0
    end

    -- Send text to the persistent terminal's stdin. Only open/create (toggle) when needed;
    -- if the session is already running and the window is open, do not toggle (would close it).
    local function send_to_persistent_terminal(text)
      if not text or text == '' then
        return
      end
      local st = agent._term_state
      local win_open = st and st.win and vim.api.nvim_win_is_valid(st.win)
      local has_live_job = st and job_is_alive(st.job_id)

      if has_live_job then
        if not win_open then
          agent.toggle_terminal()
        end
        vim.fn.chansend(st.job_id, text .. '\n')
      else
        agent.toggle_terminal()
        st = agent._term_state
        if st and st.job_id and st.job_id > 0 then
          vim.fn.chansend(st.job_id, text .. '\n')
        end
      end
    end

    -- toggle agent
    vim.keymap.set('n', '<leader>a', ':CursorAgent<CR>', { desc = 'Cursor Agent: Toggle' })

    -- selection: send to persistent terminal (one session).
    vim.keymap.set('v', '<leader>a', function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
      vim.schedule(function()
        local sel = get_visual_selection_from_buf(bufnr)
        if sel == '' then
          vim.notify('No selection', vim.log.levels.WARN, { title = 'cursor-agent' })
          return
        end
        send_to_persistent_terminal(sel)
      end)
    end, { desc = 'Cursor Agent: Ask selection' })

    -- same as leader a in visual, but send file path instead of selection
    vim.keymap.set('n', '<leader>A', function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
      vim.schedule(function()
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path == '' then
          vim.notify('Buffer has no file path', vim.log.levels.WARN, { title = 'cursor-agent' })
          return
        end
        local file = vim.fn.fnamemodify(path, ':.')
        send_to_persistent_terminal('@' .. file)
      end)
    end, { desc = 'Cursor Agent: Ask about file (path)' })

    -- selection + what does this do (send to persistent terminal)
    vim.keymap.set('v', '<leader>e', function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
      vim.schedule(function()
        local sel = get_visual_selection_from_buf(bufnr)
        if sel == '' then
          vim.notify('No selection', vim.log.levels.WARN, { title = 'cursor-agent' })
          return
        end
        send_to_persistent_terminal(sel .. '\n\nwhat does this do?')
      end)
    end, { desc = 'Cursor Agent: What does this do?' })

    -- selection + code review (send to persistent terminal)
    vim.keymap.set('v', '<leader>r', function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
      vim.schedule(function()
        local sel = get_visual_selection_from_buf(bufnr)
        if sel == '' then
          vim.notify('No selection', vim.log.levels.WARN, { title = 'cursor-agent' })
          return
        end
        send_to_persistent_terminal(sel .. '\n\nreview this code, flag any concerns and suggest any improvements, do not make any changes')
      end)
    end, { desc = 'Cursor Agent: review this code' })
  end,
}
