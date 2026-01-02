#!/bin/bash
set -e

# Arch Linux setup script for dotfiles
# Mirrors the Debian/Ubuntu setup

echo "=== Dotfiles Arch Linux Setup ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    error "Please run as a regular user, not root. Script will use sudo when needed."
    exit 1
fi

# Update package database
info "Updating package database..."
sudo pacman -Sy

# =============================================================================
# Install yay (AUR helper) if not present
# =============================================================================
info "Checking for yay (AUR helper)..."
if ! command -v yay &> /dev/null; then
    info "Installing yay from AUR..."
    sudo pacman -S --needed --noconfirm base-devel git
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd
    rm -rf "$TEMP_DIR"
    info "yay installed"
else
    info "yay already installed"
fi

# =============================================================================
# Core packages from pacman
# =============================================================================
info "Installing core packages from pacman..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    curl \
    wget \
    unzip \
    gnupg \
    ca-certificates \
    zsh \
    stow \
    htop \
    tmux \
    tig \
    nmap \
    inetutils \
    graphviz \
    restic \
    ncmpcpp \
    python-pipx \
    luarocks \
    xclip \
    cmake \
    gettext \
    ninja \
    fd \
    ripgrep \
    postgresql-libs \
    mysql-clients

# =============================================================================
# Zsh setup
# =============================================================================
info "Setting up Zsh..."

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    warn "Shell changed. Log out and back in for it to take effect."
fi

# =============================================================================
# Build Neovim from source
# =============================================================================
info "Building Neovim from source..."

NVIM_VERSION="v0.11.5"
NVIM_BUILD_DIR="/tmp/neovim-build"

# Install build dependencies
sudo pacman -S --needed --noconfirm \
    ninja \
    cmake \
    unzip \
    curl \
    base-devel

# Clone and build
if command -v nvim &> /dev/null; then
    CURRENT_VERSION=$(nvim --version | head -1 | grep -oP 'v[\d.]+')
    if [ "$CURRENT_VERSION" = "$NVIM_VERSION" ]; then
        info "Neovim $NVIM_VERSION already installed, skipping build"
    else
        warn "Neovim $CURRENT_VERSION installed, upgrading to $NVIM_VERSION"
        BUILD_NVIM=true
    fi
else
    BUILD_NVIM=true
fi

if [ "${BUILD_NVIM:-false}" = true ] || [ ! -f /usr/local/bin/nvim ]; then
    rm -rf "$NVIM_BUILD_DIR"
    git clone --depth 1 --branch "$NVIM_VERSION" https://github.com/neovim/neovim.git "$NVIM_BUILD_DIR"
    cd "$NVIM_BUILD_DIR"
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    cd -
    rm -rf "$NVIM_BUILD_DIR"
    info "Neovim $NVIM_VERSION installed"
fi

# =============================================================================
# fzf (from git for latest version with shell integration)
# =============================================================================
info "Installing fzf..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
else
    info "fzf already installed"
fi

# =============================================================================
# GitHub CLI (gh)
# =============================================================================
info "Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
    sudo pacman -S --needed --noconfirm github-cli
else
    info "gh already installed"
fi

# =============================================================================
# lazygit
# =============================================================================
info "Installing lazygit..."
if ! command -v lazygit &> /dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
else
    info "lazygit already installed"
fi

# =============================================================================
# Go
# =============================================================================
info "Installing Go..."
GO_VERSION="1.22.0"
export PATH=$PATH:/usr/local/go/bin
if [ -x /usr/local/go/bin/go ]; then
    info "Go already installed: $(/usr/local/go/bin/go version)"
else
    curl -Lo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    info "Go $GO_VERSION installed"
fi

# =============================================================================
# NVM and Node.js
# =============================================================================
info "Installing NVM and Node.js..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
else
    info "NVM already installed"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# =============================================================================
# Bun
# =============================================================================
info "Installing Bun..."
if [ -x "$HOME/.bun/bin/bun" ]; then
    info "Bun already installed: $($HOME/.bun/bin/bun --version)"
else
    curl -fsSL https://bun.sh/install | bash
fi

# =============================================================================
# Terraform
# =============================================================================
info "Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    sudo pacman -S --needed --noconfirm terraform
else
    info "Terraform already installed"
fi

# =============================================================================
# kubectl
# =============================================================================
info "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    sudo pacman -S --needed --noconfirm kubectl
else
    info "kubectl already installed"
fi

# =============================================================================
# AWS CLI
# =============================================================================
info "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip -q /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
    rm -rf /tmp/awscliv2.zip /tmp/aws
else
    info "AWS CLI already installed"
fi

# =============================================================================
# Pulumi
# =============================================================================
info "Installing Pulumi..."
if [ -x "$HOME/.pulumi/bin/pulumi" ]; then
    info "Pulumi already installed: $($HOME/.pulumi/bin/pulumi version)"
else
    curl -fsSL https://get.pulumi.com | sh
fi

# =============================================================================
# DigitalOcean CLI (doctl)
# =============================================================================
info "Installing doctl..."
if ! command -v doctl &> /dev/null; then
    DOCTL_VERSION=$(curl -s "https://api.github.com/repos/digitalocean/doctl/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/doctl.tar.gz "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"
    tar xf /tmp/doctl.tar.gz -C /tmp
    sudo install /tmp/doctl /usr/local/bin
    rm /tmp/doctl.tar.gz /tmp/doctl
else
    info "doctl already installed"
fi

# =============================================================================
# wakeonlan (from AUR if needed)
# =============================================================================
info "Installing wakeonlan..."
if ! command -v wakeonlan &> /dev/null; then
    yay -S --needed --noconfirm wakeonlan
else
    info "wakeonlan already installed"
fi

# =============================================================================
# Python tools via pipx
# =============================================================================
info "Installing Python tools via pipx..."
pipx ensurepath

# awslogs
if ! command -v awslogs &> /dev/null; then
    pipx install awslogs
fi

# uv (Python package manager)
if ! command -v uv &> /dev/null; then
    pipx install uv
fi

# =============================================================================
# Ghostty (only if GUI available)
# =============================================================================
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ] || [ "$XDG_SESSION_TYPE" = "x11" ] || [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    info "Installing Ghostty..."
    if ! command -v ghostty &> /dev/null; then
        yay -S --needed --noconfirm ghostty
    else
        info "Ghostty already installed"
    fi
else
    info "Skipping Ghostty (no GUI detected)"
fi

# =============================================================================
# Stow dotfiles
# =============================================================================
info "Linking dotfiles with stow..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Backup files that would conflict with stow
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing .zshrc to $BACKUP"
    mv "$HOME/.zshrc" "$BACKUP"
fi

# Run stow
stow -R -v --dotfiles -t ~ home

# =============================================================================
# Post-install notes
# =============================================================================
echo ""
echo "=========================================="
echo -e "${GREEN}Setup complete!${NC}"
echo "=========================================="
echo ""
echo "Notes:"
echo "  - Log out and back in for zsh to become your default shell"
echo "  - Run 'nvim' to trigger lazy.nvim plugin installation"
echo "  - Run 'gh auth login' to authenticate GitHub CLI"
echo "  - Run 'aws configure' to set up AWS credentials"
echo ""
echo "Skipped (macOS only):"
echo "  - skhd (macOS hotkey daemon)"
echo ""
echo "Manual installs if needed:"
echo "  - cf-terraforming: https://github.com/cloudflare/cf-terraforming"
echo "  - HCP CLI: https://developer.hashicorp.com/hcp/docs/cli"
echo ""
