-- autopairs
-- https://github.com/windwp/nvim-autopairs
-- Note: blink.cmp has built-in auto_brackets for function completions,
-- so we don't need the cmp integration here anymore.

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {},
}
