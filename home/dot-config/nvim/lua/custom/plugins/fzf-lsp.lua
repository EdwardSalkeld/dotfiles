return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
    config = function()
      local fzf = require 'fzf-lua'

      fzf.setup {
        winopts = {
          height = 0.8,
          width = 0.8,
          preview = {
            layout = 'horizontal',
            horizontal = 'right:50%',
          },
        },
        fzf_opts = { ['--cycle'] = true },
      }

      -- Files / grep / buffers
      vim.keymap.set('n', '<leader>dd', fzf.files, { desc = 'FZF: Find files' })
      vim.keymap.set('n', '<leader>dg', fzf.live_grep, { desc = 'FZF: Live grep' })
      vim.keymap.set('n', '<leader>db', fzf.buffers, { desc = 'FZF: Buffers' })

      -- LSP (via fzf-lua)
      vim.keymap.set('n', '<leader>ds', fzf.lsp_document_symbols, { desc = 'FZF: Document symbols' })
      vim.keymap.set('n', '<leader>dS', fzf.lsp_live_workspace_symbols, { desc = 'FZF: Workspace symbols (live)' })
      vim.keymap.set('n', '<leader>dr', fzf.lsp_references, { desc = 'FZF: References' })
      vim.keymap.set('n', '<leader>ddf', fzf.lsp_definitions, { desc = 'FZF: Definitions' })
      vim.keymap.set('n', '<leader>di', fzf.lsp_implementations, { desc = 'FZF: Implementations' })

      -- Diagnostics (correct names)
      vim.keymap.set('n', '<leader>dx', fzf.diagnostics_document, { desc = 'FZF: Document diagnostics' })
      vim.keymap.set('n', '<leader>dX', fzf.diagnostics_workspace, { desc = 'FZF: Workspace diagnostics' })
    end,
  },
}
