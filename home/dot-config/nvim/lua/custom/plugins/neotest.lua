return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
    'nvim-neotest/neotest-go',
  },
  keys = {
    { '<leader>tn', function() require('neotest').run.run() end, desc = 'Run nearest test' },
    { '<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, desc = 'Run file tests' },
    { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Toggle test summary' },
    { '<leader>to', function() require('neotest').output.open { enter = true } end, desc = 'Show test output' },
    { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle output panel' },
    { '<leader>tS', function() require('neotest').run.stop() end, desc = 'Stop test' },
    { '[T', function() require('neotest').jump.prev { status = 'failed' } end, desc = 'Prev failed test' },
    { ']T', function() require('neotest').jump.next { status = 'failed' } end, desc = 'Next failed test' },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-python' {
          -- Default: pytest. Change to 'django' or 'unittest' as needed
          runner = 'pytest',
          -- For Docker workflows, you can wrap with a script or use:
          -- python = 'docker compose exec django python',
        },
        require 'neotest-go',
      },
      status = { virtual_text = true },
      output = { open_on_run = false },
    }
  end,
}
