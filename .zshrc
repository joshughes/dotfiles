# Authoritative zshrc managed by this dotfiles repo

export PATH="$HOME/.local/bin:$PATH"

# Reuse bash aliases
if [ -f "$HOME/.bash_aliases" ]; then
  source "$HOME/.bash_aliases"
fi

# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

export HISTFILE=/commandhistory/.bash_history
export HISTFILESIZE=20000
