vim.keymap.set({ 'n', 'v' }, 'ee', '$', { desc = 'Jump to end of line' })
vim.keymap.set('i', 'jj', '<Esc>')

-- For moving text up and down
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })

vim.keymap.set('n', '<leader>d', function()
  vim.diagnostic.open_float(nil, { scope = 'line', focusable = true })

  vim.api.nvim_buf_set_keymap(0, 'n', '<Esc>', '<Cmd>close<CR>', { noremap = true, silent = true })
end, { desc = 'Show line diagnostics (Esc to close)' })

vim.keymap.set('n', '<leader>yd', function()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(0, { lnum = line })
  if #diags > 0 then
    -- concatenate all messages with a separator
    local messages = table.concat(
      vim.tbl_map(function(d)
        return d.message
      end, diags),
      ' | '
    )
    vim.fn.setreg('+', messages)
  else
    print 'No diagnostics on this line'
  end
end, { desc = 'Copy line diagnostics to system clipboard' })

vim.keymap.set('n', '<leader>O', ':put! _<CR>j', { desc = 'Add blank line above' })
vim.keymap.set('n', '<leader>o', ':put _<CR>k', { desc = 'Add blank line below' })

vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

--YANKY
vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)')
vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')

vim.keymap.set('n', '<c-p>', '<Plug>(YankyPreviousEntry)')
vim.keymap.set('n', '<c-n>', '<Plug>(YankyNextEntry)')

vim.keymap.set('n', '<leader>p', '<Plug>(YankyPutAfterLinewise)', { desc = 'Linewise paste after' })
vim.keymap.set('n', '<leader>P', '<Plug>(YankyPutBeforeLinewise)', { desc = 'Linewise paste before' })

-- Save with Ctrl-s
vim.api.nvim_set_keymap('i', '<C-s>', '<C-o>:w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })

-- Dont yank when using X
vim.api.nvim_set_keymap('n', 'x', '"_x', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'x', '"_x', { noremap = true, silent = true })

-- CodeDiff
vim.keymap.set('n', '<leader>cd', ':CodeDiff<CR>', { desc = 'CodeDiff' })

-- fast escape from terminal mode
vim.keymap.set('t', '<Esc>', [[<C-\><C-n><cmd>close<CR>]], { silent = true })
