#!/usr/bin/env bash
# Box bootstrap: link a curated subset of these dotfiles into the sandbox and
# install editor/mux plugins. Runs as `edward` on every `sbx up`/`recreate` (via
# dev-sandboxes' lib/provision.sh). Idempotent. Heavy toolchain is baked into the
# image; this is only the per-boot linking + plugin sync.
#
# We link out to the shared, portable configs in home/ (single source of truth)
# and skip the mac-only ones (aerospace/ghostty/borders/ncmpcpp, dot-claude —
# ~/.claude is a host mount). When something must diverge for linux, point the
# link at a linux-specific file instead of the home/ one.
set -uo pipefail

DOT="$HOME/personal/dotfiles/home"

# nvim/tools write here — keep box-local, NOT in the mounted dotfiles.
mkdir -p ~/.local/share ~/.local/state ~/.cache ~/.config

link() { ln -sfn "$1" "$2"; }
link "$DOT/dot-zshrc"                  ~/.zshrc
link "$DOT/dot-vimrc"                  ~/.vimrc
link "$HOME/personal/dotfiles/sbx-tmux.conf" ~/.tmux.conf   # box override: sources shared + clipboard
link "$DOT/dot-config/nvim"            ~/.config/nvim
link "$DOT/dot-local/bin"              ~/.local/bin
link "$DOT/dot-local/tmux"             ~/.local/tmux
echo "  linked: .zshrc .vimrc .tmux.conf(box) .config/nvim .local/{bin,tmux}"

# Neovim plugins (Kickstart + lazy.nvim self-bootstrap; restore pins to lazy-lock).
if [ ! -d ~/.local/share/nvim/lazy/lazy.nvim ]; then
  echo "  nvim: installing plugins (first run)…"
  nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || true
fi

# tmux plugins (tpm is baked into the image).
[ -x ~/.tmux/plugins/tpm/bin/install_plugins ] && ~/.tmux/plugins/tpm/bin/install_plugins >/dev/null 2>&1 || true

echo "  dotfiles bootstrap done"
