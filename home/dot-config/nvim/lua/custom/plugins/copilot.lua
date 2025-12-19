return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false }, -- suggestion = {
        --   auto_trigger = true,
        -- },
      }
    end,
    -- 'olimorris/codecompanion.nvim',
    -- event = 'InsertEnter',
    -- opts = {},
    -- dependencies = {
    --   'nvim-lua/plenary.nvim',
    --   'nvim-treesitter/nvim-treesitter',
    -- },
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
