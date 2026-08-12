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
    -- Fork of nfrid/markdown-togglecheck: upstream requires the removed
    -- `nvim-treesitter.ts_utils` module and breaks on nvim-treesitter's `main`
    -- branch. The fork uses the Neovim built-in instead. Upstream PR pending.
    'EdwardSalkeld/markdown-togglecheck',
    branch = 'fix-nvim-treesitter-main-compat',
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
