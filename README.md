# Dotfiles for Ubuntu Devcontainers

These dotfiles are optimized for Ubuntu-based VS Code Dev Containers (and Codespaces). The setup installs Starship and symlinks core dotfiles from this repo so your config is identical on every machine/container.

## Quick Start (Dev Containers / Codespaces)

- Set VS Code to use this repo as your dotfiles:
  - Open Command Palette → "Preferences: Open User Settings (JSON)" and add:
    ```json
    {
      "dotfiles.repository": "OWNER/REPO",
      "dotfiles.installCommand": "./install.sh"
    }
    ```
    Replace `OWNER/REPO` with your GitHub repo path.
- Rebuild/reopen your dev container. The extension clones this repo to `~/.dotfiles` and runs `./install.sh` automatically.

## Local install (optional)

If you want to test locally on Ubuntu:

```bash
git clone https://github.com/OWNER/REPO.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```
Open a new shell after installation.

## What you get

- Starship prompt configured and enabled in bash (and zsh if present)
- Git branch/status in the prompt out of the box
- Minimal, readable prompt; no extra noise
- Helpful defaults:
  - `.bash_aliases` with `ll`, `gs`, `gl`, etc.
  - `.inputrc` for case-insensitive completion and history search with arrows
  - `.editorconfig` for consistent indentation/newlines
  - A small Git config included into `~/.gitconfig` (colors, `init.defaultBranch=main`, prune on fetch)

## Files in this repo

- `install.sh`: Idempotent setup script for Ubuntu devcontainers
- `.bashrc` / `.zshrc`: Authoritative shell configs (symlinked to `$HOME`)
- `.config/starship.toml`: Starship prompt settings (shows git branch/status)
- `.bash_aliases`: Common, minimal aliases
- `.inputrc`: Better completion and history search
- `.editorconfig`: Basic editor defaults
- `.gitconfig`: Git defaults (symlinked to `$HOME/.gitconfig`)

## Customizing Starship

Edit `~/.config/starship.toml` (it’s symlinked to this repo’s file). A few quick tweaks you might like:

```toml
# Always keep the prompt on one line
add_newline = false

[git_branch]
symbol = " "            # or simply " " / "branch: "
truncation_length = 32
style = "bold purple"

[git_status]
# Keep this enabled to see dirty/clean state
# disabled = false
```

Starship’s full module list and options: https://starship.rs/config/

## Adding more dotfiles

- Put new files in this repo and link them in `install.sh` using the `link_file` helper. Examples:
  - Add a custom `~/.vimrc`: create `vim/.vimrc` in this repo and add `link_file "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"`.
  - Add a `.gitignore_global`: create `.gitignore_global` here and link to `$HOME/.gitignore_global`.
- This installer backs up existing files (e.g., `~/.bashrc.bak`) and replaces them with symlinks so the repo remains the single source of truth.

## Notes

- The installer installs Starship to `~/.local/bin` without sudo using the official script. If `curl` is missing and sudo is available, it installs `curl` via apt.
- Works with bash and zsh (both are symlinked from this repo). Starship loads if installed.
- Re-run `./install.sh` any time; it’s safe and idempotent.

## Troubleshooting

- After installation, if Starship isn’t found, ensure `~/.local/bin` is on your `PATH` and open a new shell:
  ```bash
  export PATH="$HOME/.local/bin:$PATH"; exec bash
  ```
- To verify Starship: `starship --version`

---
Happy hacking!
