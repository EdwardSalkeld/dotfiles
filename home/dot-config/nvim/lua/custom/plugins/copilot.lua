-- Copilot - lazy loaded on demand via :CopilotEnable
-- Uses ~900MB per instance, so only enable when you really need it
-- With blink.cmp, we use copilot's native inline suggestion mode
return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'CopilotEnable', -- only load when this command is run
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = '<M-l>', -- Alt+l to accept suggestion
            accept_word = '<M-w>', -- Alt+w to accept word
            accept_line = '<M-j>', -- Alt+j to accept line
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<M-e>',
          },
        },
        panel = { enabled = false },
      }
      print 'Copilot enabled (use Alt+l to accept suggestions)'
    end,
  },
}
