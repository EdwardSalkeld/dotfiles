-- Copilot - lazy loaded on InsertEnter
-- With blink.cmp, we use copilot's native inline suggestion mode
return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter', -- Load when first entering insert mode
    config = function()
      -- Style copilot suggestions as light grey
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#808080', italic = true })

      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = '<C-k>', -- Ctrl+k to accept full suggestion
            accept_word = '<C-h>', -- Ctrl+h to accept word
            accept_line = '<C-j>', -- Ctrl+j to accept line
            next = '<C-]>',
            prev = '<C-\\>', -- Note: <C-[> is same as Esc!
            dismiss = '<C-e>',
          },
        },
        panel = { enabled = false },
      }
    end,
  },
}
