# Sourced from ~/.zshrc by install.sh.

# Auto-attach to a "main" tmux session on login (skipped inside VS Code terminals).
if [ -z "$TMUX" ] && [ -z "$VSCODE_INJECTION" ] && command -v tmux &>/dev/null; then
  tmux attach-session -t main 2>/dev/null || tmux new-session -s main
fi

# hunk-toggle.sh lives in ~/bin; hunk's installer uses ~/.hunk/bin.
export PATH="$HOME/bin:$HOME/.hunk/bin:$HOME/.local/bin:$PATH"

# Let agent-deck run inside the outer "main" tmux so Ctrl+Z can open a hunk pane
# beside it. Detach is Ctrl+A (see agent-deck/config.toml), so the outer-tmux
# Ctrl+Q conflict this guard protects against doesn't apply.
export AGENT_DECK_ALLOW_OUTER_TMUX=1

# Root that hunk-toggle.sh scans for repos when the pane's cwd isn't one:
# $HUNK_PROJ_ROOT/<project>/<worktree>
export HUNK_PROJ_ROOT="${HUNK_PROJ_ROOT:-$HOME/projects}"
