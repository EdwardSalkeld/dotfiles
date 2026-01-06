-- Copilot - lazy loaded on demand via :CopilotEnable
-- Uses ~900MB per instance, so only enable when you really need it
return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'CopilotEnable', -- only load when this command is run
    config = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
      require('copilot_cmp').setup()
      print 'Copilot enabled'
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    lazy = true, -- loaded by copilot.lua config above
  },
}
