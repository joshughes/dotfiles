#!/usr/bin/env bash
set -euo pipefail

# Minimal, idempotent installer for Ubuntu-based devcontainers.
# - Installs Starship to ~/.local/bin (no sudo required)
# - Symlinks core dotfiles from this repo so config is identical everywhere

log() { printf "[dotfiles] %s\n" "$*"; }
warn() { printf "[dotfiles][warn] %s\n" "$*"; }

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

mkdir -p "$HOME/.local/bin" "$HOME/.config"

# Ensure ~/.local/bin is on PATH for non-login shells that skip ~/.profile
ensure_local_bin_in_path() { :; }

install_starship() {
  if command -v starship >/dev/null 2>&1; then
    log "Starship already installed: $(command -v starship)"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    if command -v sudo >/dev/null 2>&1; then
      log "Installing curl via apt (requires sudo)…"
      sudo apt-get update -y && sudo apt-get install -y curl
    elif [ "${EUID:-$(id -u)}" -eq 0 ] 2>/dev/null; then
      log "Installing curl via apt as root…"
      apt-get update -y && apt-get install -y curl
    else
      warn "curl not found and sudo not available. Please install curl and re-run."
      return 1
    fi
  fi

  log "Installing Starship to ~/.local/bin…"
  # Official installer expects POSIX sh, not bash. See: https://starship.rs
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
}

wire_shell_init() { :; }

link_file() {
  # link_file <source> <target>
  local src="$1"; shift
  local dst="$1"; shift
  local dst_dir
  dst_dir="$(dirname "$dst")"
  mkdir -p "$dst_dir"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    # If already linked to our source, nothing to do
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
      return 0
    fi
    # Backup existing and replace with our link to keep config uniform
    local backup="$dst.bak"
    warn "Backing up existing $dst -> $backup"
    rm -rf "$backup" 2>/dev/null || true
    mv "$dst" "$backup"
  fi
  ln -s "$src" "$dst"
  log "Linked $(basename "$src") -> $dst"
}

configure_git_include() {
  local include_path="$DOTFILES_DIR/git/.gitconfig"
  mkdir -p "$HOME/.config/git"

  if [ ! -f "$include_path" ]; then
    return 0
  fi

  local user_gitconfig="$HOME/.gitconfig"
  local marker="# >>> dotfiles: git include >>>"
  if [ -f "$user_gitconfig" ] && grep -q "$include_path" "$user_gitconfig" 2>/dev/null; then
    return 0
  fi

  log "Including dotfiles git config in ~/.gitconfig"
  {
    echo "$marker"
    echo "[include]"
    echo "    path = $include_path"
    echo "# <<< dotfiles: git include <<<"
  } >> "$user_gitconfig"
}

main() {
  ensure_local_bin_in_path
  install_starship

  # Link configs (authoritative from this repo)
  link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
  link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  link_file "$DOTFILES_DIR/.inputrc" "$HOME/.inputrc"
  link_file "$DOTFILES_DIR/.editorconfig" "$HOME/.editorconfig"
  link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  link_file "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

  log "Done. Open a new shell or 'exec bash' to reload."
}

main "$@"
