return {
  'xTacobaco/cursor-agent.nvim',

  config = function()
    -- current file relative to cwd (what Cursor Agent expects)
    local function current_file_path()
      local path = vim.api.nvim_buf_get_name(0)
      if path == '' then
        return ''
      end
      return vim.fn.fnamemodify(path, ':.')
    end

    local agent = require 'cursor-agent'

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

    -- file reference (actual path)
    vim.keymap.set('n', '<leader>A', function()
      local file = current_file_path()
      open_agent_with('@' .. file .. ' ')
    end, { desc = 'Cursor Agent: Ask about file' })

    -- Get visual selection from a specific buffer (uses that buffer's '< and '> marks).
    -- nvim_buf_get_mark uses 1-based line, 0-based column; get_lines uses 0-based end-exclusive.
    local function get_visual_selection_from_buf(bufnr)
      local start_pos = vim.api.nvim_buf_get_mark(bufnr, '<')
      local end_pos = vim.api.nvim_buf_get_mark(bufnr, '>')
      if not start_pos or not end_pos then
        return ''
      end
      local start_row, start_col = start_pos[1], start_pos[2] -- 1-based line, 0-based col
      local end_row, end_col = end_pos[1], end_pos[2]
      local r1 = math.min(start_row, end_row)
      local r2 = math.max(start_row, end_row)
      local c1 = math.min(start_col, end_col)
      local c2 = math.max(start_col, end_col)
      if vim.opt.selection:get() == 'exclusive' and c2 > 0 then
        c2 = c2 - 1
      end
      local lines = vim.api.nvim_buf_get_lines(bufnr, r1 - 1, r2, false)
      if not lines or #lines == 0 then
        return ''
      end
      -- string.sub is 1-based; columns from API are 0-based
      local c1_1, c2_1 = c1 + 1, c2 + 1
      if r1 == r2 then
        lines[1] = string.sub(lines[1], c1_1, c2_1)
      else
        lines[1] = string.sub(lines[1], c1_1)
        lines[#lines] = string.sub(lines[#lines], 1, c2_1)
      end
      return table.concat(lines, '\n')
    end

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
