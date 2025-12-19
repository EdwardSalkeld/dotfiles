# Dotfiles Repository

A personal dotfiles repository for macOS, managed with GNU Stow. Contains shell configuration, custom scripts, and a comprehensive Neovim setup based on kickstart.nvim.

## Repository Structure

```
dotfiles/
├── up.sh / down.sh          # Stow management scripts
├── setup-debian.sh          # Debian/Ubuntu setup script
├── brew.list                 # Homebrew packages
├── code-samples/             # Syntax highlighting test files
└── home/                     # Symlinked to ~ via stow
    ├── dot-zshrc             # Zsh configuration
    ├── dot-config/
    │   ├── nvim/             # Neovim configuration
    │   ├── ghostty/          # Terminal emulator
    │   ├── skhd/             # macOS hotkey daemon
    │   └── ncmpcpp/          # Music player config
    └── dot-local/
        ├── bin/              # Custom shell scripts
        └── tmux/             # Tmux session templates
```

## Setup

### macOS (Homebrew)

```bash
brew bundle --file=brew.list  # Install packages
./up.sh                       # Symlink dotfiles
```

### Debian/Ubuntu

```bash
./setup-debian.sh  # Full setup: packages, zsh, neovim from source, stow
```

The Debian script handles:
- Core apt packages (fd, ripgrep, tmux, tig, htop, etc.)
- Zsh installation and Oh My Zsh setup
- Building Neovim from source (latest stable)
- External tools via official repos (gh, terraform, kubectl)
- Binary installs (lazygit, doctl, Go)
- NVM + Node.js, Bun
- Python tools via pipx (awslogs, uv)
- AWS CLI v2
- Pulumi
- Stow linking of dotfiles

### Unlink

```bash
./down.sh  # Remove symlinks (both platforms)
```

## Custom Scripts

Located in `home/dot-local/bin/`:

| Script | Purpose |
|--------|---------|
| `swap-session` | Switch tmux sessions with fzf (searches ~/code, ~/develop, ~/personal) |
| `swap-window` | Switch tmux windows with fzf |
| `copy` | Cross-platform clipboard utility |
| `push-to-staging` | Force push to staging branch with confirmation |
| `daynote` | Daily note-taking utility |
| `brew-install/save` | Homebrew management helpers |

## Shell Configuration

**Zsh** with Oh My Zsh (robbyrussell theme):
- Git and AWS plugins
- NVM for Node version management
- FZF integration for history search
- Custom aliases for navigation (`rdot`, `rweb`, `rtt`, `rnot`)

## Neovim Configuration

A Lua-based setup using **lazy.nvim** plugin manager with Catppuccin colorscheme.

### Key Bindings

| Mapping | Action |
|---------|--------|
| `<Space>` | Leader key |
| `<leader><leader>` | Find files (Telescope) |
| `<leader>/` | Grep search |
| `<leader>b` | Browse buffers |
| `\` | Toggle Neo-tree file browser |
| `<leader>f` | Format buffer |
| `<leader>gg` | Open Lazygit |
| `<leader>rt` | Run Django test at cursor |
| `<leader>tt` | Toggle light/dark theme |

### LSP Keybindings

| Mapping | Action |
|---------|--------|
| `grn` | Rename symbol |
| `gra` | Code action |
| `grr` | Find references |
| `grd` | Go to definition |
| `gri` | Go to implementations |
| `gO` | Document symbols |

### Language Support

**LSP Servers:**
- Python: ruff, ty, basepyright
- TypeScript/JavaScript: vtsls, biome
- Go: gopls
- Markdown: marksman
- Docker: dockerfile-language-server
- Terraform: terraform-ls

**Formatters:**
- Lua: stylua
- JS/TS: biome (2-space indent)
- Markdown: prettierd
- Go: gofumpt, goimports
- SQL: sqlfmt

### Notable Plugins

- **Telescope** - Fuzzy finder with fzf backend
- **Neo-tree** - File explorer
- **Treesitter** - Syntax highlighting
- **Gitsigns** - Git hunks in gutter
- **Neogit** - Git UI with diffview
- **Snacks.nvim** - Git log, lazygit integration
- **GitHub Copilot** - AI completion
- **Which-key** - Keymap discovery
- **Auto-dark-mode** - System theme sync
- **Todo-comments** - Highlight TODO/FIXME/HACK

### Django Test Runner

Custom function to run Django tests from within Neovim:
- Automatically detects test class and method at cursor
- Runs via `docker compose exec` in floating terminal
- Bound to `<leader>rt`

## Terminal & System

**Ghostty** - Modern terminal with Catppuccin theme, Ubuntu Mono font

**Skhd** - Global hotkeys:
- `Cmd+Fn+F1` Ghostty
- `Cmd+Fn+F2` Firefox
- `Cmd+Fn+F3` Outlook
- `Cmd+Fn+F4` Slack
- `Cmd+Fn+F5` Linear

## Homebrew Packages

Key packages from `brew.list`:
- **Dev**: neovim, go, node, nvm, bun, terraform, pulumi
- **CLI**: fd, fzf, ripgrep, lazygit, gh, tig
- **System**: htop, stow, skhd
- **Cloud**: awscli, doctl, cloudflare
