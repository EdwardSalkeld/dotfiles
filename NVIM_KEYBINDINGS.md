# Neovim Keybindings Cheat Sheet

Generated from dotfiles config. Leader key is `<Space>`.

---

## General / Built-in

| Key          | Mode | Action                                        | Source   |
| ------------ | ---- | --------------------------------------------- | -------- |
| `<Esc>`      | n    | Clear search highlights                       | init.lua |
| `<leader>q`  | n    | Open diagnostic quickfix list                 | init.lua |
| `<Esc><Esc>` | t    | Exit terminal mode                            | init.lua |
| `yp`         | n    | Yank current file path (relative to git root) | init.lua |

## Navigation

| Key     | Mode    | Action                      | Source             |
| ------- | ------- | --------------------------- | ------------------ |
| `<C-h>` | n       | Navigate left (tmux-aware)  | vim-tmux-navigator |
| `<C-j>` | n       | Navigate down (tmux-aware)  | vim-tmux-navigator |
| `<C-k>` | n       | Navigate up (tmux-aware)    | vim-tmux-navigator |
| `<C-l>` | n       | Navigate right (tmux-aware) | vim-tmux-navigator |
| `gs`    | n, x, o | Flash jump                  | flash.nvim         |
| `gS`    | n, x, o | Flash treesitter            | flash.nvim         |
| `r`     | o       | Remote flash                | flash.nvim         |
| `R`     | o, x    | Treesitter search           | flash.nvim         |
| `<C-s>` | c       | Toggle flash search         | flash.nvim         |

## File Explorer

| Key | Mode | Action                         | Source        |
| --- | ---- | ------------------------------ | ------------- |
| `\` | n    | Toggle NeoTree / Close NeoTree | neo-tree.nvim |

## Telescope (Fuzzy Finding)

| Key                | Mode | Action                         | Source         |
| ------------------ | ---- | ------------------------------ | -------------- |
| `<leader><leader>` | n    | Find files                     | telescope.nvim |
| `<leader>/`        | n    | Live grep                      | telescope.nvim |
| `<leader>,`        | n    | Find existing buffers          | telescope.nvim |
| `<leader>b`        | n    | Fuzzy search in current buffer | telescope.nvim |
| `<leader>sh`       | n    | Search help                    | telescope.nvim |
| `<leader>sk`       | n    | Search keymaps                 | telescope.nvim |
| `<leader>ss`       | n    | Search select Telescope        | telescope.nvim |
| `<leader>sw`       | n    | Search current word            | telescope.nvim |
| `<leader>sd`       | n    | Search diagnostics             | telescope.nvim |
| `<leader>sr`       | n    | Search resume (last search)    | telescope.nvim |
| `<leader>s/`       | n    | Grep including hidden files    | telescope.nvim |
| `<leader>sn`       | n    | Search Neovim config files     | telescope.nvim |
| `<leader>fr`       | n    | Search recent files            | telescope.nvim |

## LSP (when attached)

| Key         | Mode | Action                | Source         |
| ----------- | ---- | --------------------- | -------------- |
| `grn`       | n    | Rename symbol         | nvim-lspconfig |
| `gra`       | n, x | Code action           | nvim-lspconfig |
| `grr`       | n    | Go to references      | nvim-lspconfig |
| `gri`       | n    | Go to implementation  | nvim-lspconfig |
| `grd`       | n    | Go to definition      | nvim-lspconfig |
| `grD`       | n    | Go to declaration     | nvim-lspconfig |
| `grt`       | n    | Go to type definition | nvim-lspconfig |
| `gO`        | n    | Document symbols      | nvim-lspconfig |
| `gW`        | n    | Workspace symbols     | nvim-lspconfig |
| `<leader>f` | n    | Format buffer         | conform.nvim   |

## Git (Snacks)

| Key          | Mode | Action                       | Source      |
| ------------ | ---- | ---------------------------- | ----------- |
| `<leader>gg` | n    | Open Lazygit                 | snacks.nvim |
| `<leader>gl` | n    | Git log                      | snacks.nvim |
| `<leader>gL` | n    | Git log (current line)       | snacks.nvim |
| `<leader>gs` | n    | Git status                   | snacks.nvim |
| `<leader>gS` | n    | Git stash                    | snacks.nvim |
| `<leader>gd` | n    | Git diff (hunks)             | snacks.nvim |
| `<leader>gf` | n    | Git log (current file)       | snacks.nvim |
| `<leader>gB` | n, v | Git browse (open in browser) | snacks.nvim |

## Git Hunks (Gitsigns)

| Key          | Mode | Action                   | Source        |
| ------------ | ---- | ------------------------ | ------------- |
| `]c`         | n    | Next git change          | gitsigns.nvim |
| `[c`         | n    | Previous git change      | gitsigns.nvim |
| `<leader>hs` | n, v | Stage hunk               | gitsigns.nvim |
| `<leader>hr` | n, v | Reset hunk               | gitsigns.nvim |
| `<leader>hS` | n    | Stage buffer             | gitsigns.nvim |
| `<leader>hu` | n    | Undo stage hunk          | gitsigns.nvim |
| `<leader>hR` | n    | Reset buffer             | gitsigns.nvim |
| `<leader>hp` | n    | Preview hunk             | gitsigns.nvim |
| `<leader>hb` | n    | Blame line               | gitsigns.nvim |
| `<leader>hd` | n    | Diff against index       | gitsigns.nvim |
| `<leader>hD` | n    | Diff against last commit | gitsigns.nvim |

## Buffers

| Key          | Mode | Action                  | Source      |
| ------------ | ---- | ----------------------- | ----------- |
| `<leader>xx` | n    | Close current buffer    | snacks.nvim |
| `<leader>xo` | n    | Close all other buffers | snacks.nvim |

## Trouble (Diagnostics)

| Key          | Mode | Action             | Source       |
| ------------ | ---- | ------------------ | ------------ |
| `<leader>xd` | n    | Toggle diagnostics | trouble.nvim |
| `<leader>xX` | n    | Buffer diagnostics | trouble.nvim |
| `<leader>cs` | n    | Symbols            | trouble.nvim |
| `<leader>xL` | n    | Location list      | trouble.nvim |
| `<leader>xQ` | n    | Quickfix list      | trouble.nvim |

## Testing (Neotest)

| Key          | Mode | Action               | Source  |
| ------------ | ---- | -------------------- | ------- |
| `<leader>tn` | n    | Run nearest test     | neotest |
| `<leader>tf` | n    | Run file tests       | neotest |
| `<leader>tS` | n    | Toggle test summary  | neotest |
| `<leader>to` | n    | Show test output     | neotest |
| `<leader>tO` | n    | Toggle output panel  | neotest |
| `<leader>tx` | n    | Stop test            | neotest |
| `]T`         | n    | Next failed test     | neotest |
| `[T`         | n    | Previous failed test | neotest |

## Toggles

| Key          | Mode | Action                                 | Source         |
| ------------ | ---- | -------------------------------------- | -------------- |
| `<leader>ts` | n    | Toggle spell check                     | init.lua       |
| `<leader>tt` | n    | Toggle catppuccin theme (latte/frappe) | init.lua       |
| `<leader>th` | n    | Toggle inlay hints (LSP)               | nvim-lspconfig |
| `<leader>tb` | n    | Toggle git blame line                  | gitsigns.nvim  |
| `<leader>tD` | n    | Toggle git deleted inline              | gitsigns.nvim  |

## Todo Comments

| Key  | Mode | Action                | Source             |
| ---- | ---- | --------------------- | ------------------ |
| `]t` | n    | Next todo comment     | todo-comments.nvim |
| `[t` | n    | Previous todo comment | todo-comments.nvim |

## Treesitter Text Objects

| Key         | Mode | Action                       | Source                      |
| ----------- | ---- | ---------------------------- | --------------------------- |
| `af`        | v, o | Select around function       | nvim-treesitter-textobjects |
| `if`        | v, o | Select inside function       | nvim-treesitter-textobjects |
| `ac`        | v, o | Select around class          | nvim-treesitter-textobjects |
| `ic`        | v, o | Select inside class          | nvim-treesitter-textobjects |
| `aa`        | v, o | Select around parameter      | nvim-treesitter-textobjects |
| `ia`        | v, o | Select inside parameter      | nvim-treesitter-textobjects |
| `]m`        | n    | Next function start          | nvim-treesitter-textobjects |
| `[m`        | n    | Previous function start      | nvim-treesitter-textobjects |
| `]]`        | n    | Next class start             | nvim-treesitter-textobjects |
| `[[`        | n    | Previous class start         | nvim-treesitter-textobjects |
| `<leader>a` | n    | Swap parameter with next     | nvim-treesitter-textobjects |
| `<leader>A` | n    | Swap parameter with previous | nvim-treesitter-textobjects |

## Mini.nvim

| Key                  | Mode | Action                                                   | Source        |
| -------------------- | ---- | -------------------------------------------------------- | ------------- |
| `sa` + motion + char | n    | Surround add (e.g., `saiw)` adds parens around word)     | mini.surround |
| `sd` + char          | n    | Surround delete (e.g., `sd'` removes quotes)             | mini.surround |
| `sr` + old + new     | n    | Surround replace (e.g., `sr)'` changes parens to quotes) | mini.surround |

## Completion (nvim-cmp)

| Key         | Mode | Action                               | Source   |
| ----------- | ---- | ------------------------------------ | -------- |
| `<C-n>`     | i    | Next completion item                 | nvim-cmp |
| `<C-p>`     | i    | Previous completion item             | nvim-cmp |
| `<C-b>`     | i    | Scroll docs back                     | nvim-cmp |
| `<C-f>`     | i    | Scroll docs forward                  | nvim-cmp |
| `<C-y>`     | i    | Confirm completion                   | nvim-cmp |
| `<Tab>`     | i    | Confirm completion                   | nvim-cmp |
| `<C-Space>` | i    | Trigger completion                   | nvim-cmp |
| `<C-l>`     | i, s | Jump to next snippet placeholder     | LuaSnip  |
| `<C-h>`     | i, s | Jump to previous snippet placeholder | LuaSnip  |

## Spell Check

| Key          | Mode | Action                    | Source   |
| ------------ | ---- | ------------------------- | -------- |
| `<leader>ts` | n    | Toggle spell check        | init.lua |
| `]s`         | n    | Next spelling error       | built-in |
| `[s`         | n    | Previous spelling error   | built-in |
| `z=`         | n    | Show spelling suggestions | built-in |
| `zg`         | n    | Add word to dictionary    | built-in |
| `zw`         | n    | Mark word as wrong        | built-in |

## Markdown

| Key                      | Mode | Action                           | Source                |
| ------------------------ | ---- | -------------------------------- | --------------------- |
| `:MarkdownPreview`       | cmd  | Open markdown preview in browser | markdown-preview.nvim |
| `:MarkdownPreviewToggle` | cmd  | Toggle markdown preview          | markdown-preview.nvim |

---

## Leader Key Groups

| Prefix      | Purpose             |
| ----------- | ------------------- |
| `<leader>s` | Search              |
| `<leader>t` | Toggle / Test       |
| `<leader>h` | Git hunk            |
| `<leader>g` | Git                 |
| `<leader>x` | Close / Diagnostics |
| `<leader>f` | Format              |
| `gr`        | LSP go-to           |

---

## Commands

| Command          | Action                              | Source             |
| ---------------- | ----------------------------------- | ------------------ |
| `:Cppath`        | Copy current file path to clipboard | init.lua           |
| `:CopilotEnable` | Enable Copilot (lazy loaded)        | copilot.lua        |
| `:Neotree`       | Open file tree                      | neo-tree.nvim      |
| `:Neogit`        | Open Neogit                         | neogit             |
| `:Trouble`       | Open Trouble                        | trouble.nvim       |
| `:TodoTelescope` | Search todo comments                | todo-comments.nvim |
| `:ConformInfo`   | Show formatter info                 | conform.nvim       |
| `:Mason`         | Open Mason (LSP/tool installer)     | mason.nvim         |
| `:Lazy`          | Open Lazy (plugin manager)          | lazy.nvim          |
