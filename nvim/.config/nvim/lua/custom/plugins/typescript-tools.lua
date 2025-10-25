return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = {
    on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, silent = true }

      vim.keymap.set('n', 'K', function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result, ctx, config)
          if not result or not result.contents then
            vim.notify('No type information available', vim.log.levels.WARN)
            return
          end
          local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
          vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', {
            border = 'rounded',
            max_width = math.floor(vim.o.columns * 0.8),
            max_height = math.floor(vim.o.lines * 0.8),
            wrap = true,
            focus = true,
          })
        end)
      end, vim.tbl_extend('force', opts, { desc = 'Show type information' }))
    end,
  },
}
