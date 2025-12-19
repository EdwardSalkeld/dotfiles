-- lua/plugins/active_window.lua
return {
  'nvim-lua/plenary.nvim', -- harmless soft dep so lazy has a spec; remove if you don't need it
  init = function()
    -- Define small, theme-safe highlight links.
    -- We *link* to common groups so it adapts to most colorschemes.
    local function define_highlights()
      -- Stronger split color for the active window; usually readable in any theme.
      vim.api.nvim_set_hl(0, 'ActiveWindowSeparator', { link = 'Title' })
      -- Softer split for inactives.
      vim.api.nvim_set_hl(0, 'InactiveWindowSeparator', { link = 'Comment' })
      -- The 1-column left bar on the active window.
      vim.api.nvim_set_hl(0, 'ActiveWindowBar', { link = 'Visual' })
      -- No bar (blend into background) for inactives.
      vim.api.nvim_set_hl(0, 'InactiveWindowBar', { link = 'Normal' })
      -- Subtle cursorline for inactive windows (if theme defines it); keeps text readable.
      vim.api.nvim_set_hl(0, 'CursorLineNC', { link = 'CursorLine' })
    end

    define_highlights()

    local function set_active(win)
      -- Subtle helpers that work in most themes
      vim.wo[win].cursorline = true
      vim.wo[win].winhighlight = table.concat({
        'Normal:Normal',
        'NormalNC:Normal',
        'CursorLine:CursorLine',
        'ColorColumn:ActiveWindowBar',
        -- Handle both names so it works on old/new Neovim + themes
        'WinSeparator:ActiveWindowSeparator',
        'VertSplit:ActiveWindowSeparator',
        'SignColumn:SignColumn',
        'LineNr:LineNr',
        'CursorLineNr:CursorLineNr',
      }, ',')
    end

    local function set_inactive(win)
      vim.wo[win].cursorline = false
      vim.wo[win].winhighlight = table.concat({
        'Normal:NormalNC',
        'CursorLine:CursorLineNC',
        'ColorColumn:InactiveWindowBar',
        'WinSeparator:InactiveWindowSeparator',
        'VertSplit:InactiveWindowSeparator',
        'SignColumn:SignColumn',
        'LineNr:LineNr',
        'CursorLineNr:LineNr',
      }, ',')
    end

    local function refresh_all()
      local cur = vim.api.nvim_get_current_win()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative == '' then
          if w == cur then
            set_active(w)
          else
            set_inactive(w)
          end
        end
      end
    end

    local aug = vim.api.nvim_create_augroup('ActiveWindowLook', { clear = true })

    -- Reapply on colorscheme changes so links stay valid.
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = aug,
      callback = function()
        define_highlights()
        refresh_all()
      end,
    })

    -- Update whenever focus or layout changes.
    for _, ev in ipairs {
      'VimEnter',
      'WinEnter',
      'BufWinEnter',
      'WinLeave',
      'BufEnter',
      'TabEnter',
      'TabNewEntered',
      'WinNew',
      'WinClosed',
    } do
      vim.api.nvim_create_autocmd(ev, {
        group = aug,
        callback = refresh_all,
      })
    end
  end,
}
