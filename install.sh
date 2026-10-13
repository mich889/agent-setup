#!/usr/bin/env bash
# Links this repo's config into place. Existing files are moved to <file>.bak.<timestamp>.
# Does not install tmux/hunk/agent-deck/fzf themselves — see README.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
CATPPUCCIN_REV=8b0b9150f9d7dee2a4b70cdb50876ba7fd6d674a

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak.$TS"
    echo "backed up $dst -> $dst.bak.$TS"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst"
}

link "$REPO/tmux/tmux.conf"          "$HOME/.tmux.conf"
link "$REPO/bin/hunk-toggle.sh"      "$HOME/bin/hunk-toggle.sh"
link "$REPO/agent-deck/config.toml"  "$HOME/.config/agent-deck/config.toml"

# tmux.conf loads this theme with run-shell; pinned to the version it was written against.
CAT="$HOME/.config/tmux/plugins/catppuccin"
if [ ! -d "$CAT" ]; then
  git clone https://github.com/catppuccin/tmux.git "$CAT"
  git -C "$CAT" checkout -q "$CATPPUCCIN_REV"
fi

LINE="source \"$REPO/zsh/agent-setup.zsh\""
if ! grep -qF "$LINE" "$HOME/.zshrc" 2>/dev/null; then
  printf '\n# agent-setup\n%s\n' "$LINE" >> "$HOME/.zshrc"
  echo "added agent-setup.zsh to ~/.zshrc"
fi

mkdir -p "$HOME/projects"
tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo "reloaded tmux config" || true
echo "done — open a new terminal."
