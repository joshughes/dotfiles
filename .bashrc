# Authoritative bashrc managed by this dotfiles repo

# If not running interactively, don't do anything
case $- in *i*) ;; *) return;; esac

# Ensure user-local bin takes precedence
export PATH="$HOME/.local/bin:$PATH"

# Nice history behavior
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend

# Shell options
shopt -s checkwinsize

# Aliases
if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi

# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

