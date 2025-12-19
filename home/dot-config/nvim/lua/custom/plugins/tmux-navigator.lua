return {
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
  },
  keys = {
    { '<c-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Navigate Left (tmux-aware)' },
    { '<c-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Navigate Down (tmux-aware)' },
    { '<c-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Navigate Up (tmux-aware)' },
    { '<c-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate Right (tmux-aware)' },
  },
}
