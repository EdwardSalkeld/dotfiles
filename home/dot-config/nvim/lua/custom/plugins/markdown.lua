return {
  {
    {
      'iamcco/markdown-preview.nvim',
      cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
      ft = { 'markdown' },
      build = function()
        vim.fn['mkdp#util#install']()
      end,
    },
  },
  {
    'nfrid/markdown-togglecheck',
    dependencies = { 'nfrid/treesitter-utils' },
    ft = { 'markdown' },
    opts = {},
    keys = {
      {
        '<leader>mt',
        function()
          require('markdown-togglecheck').toggle()
        end,
        desc = '[M]arkdown [T]oggle checkbox',
        ft = 'markdown',
      },
      {
        '<leader>mn',
        function()
          require('markdown-togglecheck').toggle_box()
        end,
        desc = '[M]arkdown [N]ew checkbox toggle',
        ft = 'markdown',
      },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
