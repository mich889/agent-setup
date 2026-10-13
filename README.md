# agent-setup

My terminal setup for running coding agents: **tmux** + **[agent-deck](https://github.com/asheshgoplani/agent-deck)** (one tmux session per agent, with a TUI to switch between them) + **[Hunk](https://hunk.dev)** (a diff viewer that opens beside an agent with one key).

```
┌─ tmux "main" ──────────────────────────────────────────────┐
│ agent-deck session (Claude)       │ hunk diff --watch      │
│                                   │ (Ctrl+Z toggles this)  │
└────────────────────────────────────────────────────────────┘
```

## What's here

| File | Goes to | What it does |
|---|---|---|
| `tmux/tmux.conf` | `~/.tmux.conf` | Mouse, vi copy mode, Catppuccin theme, `Ctrl+Z` hunk toggle, `Alt+arrows` pane switching |
| `bin/hunk-toggle.sh` | `~/bin/hunk-toggle.sh` | Opens/closes a `hunk diff --watch` pane next to the current one |
| `agent-deck/config.toml` | `~/.config/agent-deck/config.toml` | agent-deck settings (detach key, worktrees, separate tmux socket) |
| `zsh/agent-setup.zsh` | sourced from `~/.zshrc` | Auto-attach to tmux, PATH, env vars below |
| `install.sh` | — | Symlinks the above into place, backs up anything it replaces |

## Install

### 1. Prerequisites

**macOS**
```bash
brew install tmux fzf git bash   # bash ≥4: hunk-toggle.sh uses mapfile
```

**Ubuntu / Debian**
```bash
sudo apt install tmux fzf git python3
```

Claude Code itself: https://docs.claude.com/en/docs/claude-code

### 2. Hunk
```bash
curl -fsSL https://hunk.dev/install.sh | bash   # installs to ~/.hunk/bin
```
(Also available via npm or Homebrew; `hunk update` keeps it current.)

### 3. agent-deck
```bash
brew install asheshgoplani/tap/agent-deck
# or
curl -fsSL https://raw.githubusercontent.com/asheshgoplani/agent-deck/main/install.sh | bash
```

### 4. This repo
```bash
git clone https://github.com/mich889/agent-setup.git ~/agent-setup
~/agent-setup/install.sh
```
Open a new terminal. You'll land in a tmux session called `main`.

## Daily use

1. Run `agent-deck` in the `main` tmux session. Create or open an agent session from the list.
2. Press **`Ctrl+Z`** to open a Hunk diff pane beside it; press it again to close it.
   - It diffs the repo of the pane you're in. If that isn't a git repo (the deck pane sits in `~`), it looks at agent-deck session paths and every checkout under `$HUNK_PROJ_ROOT/<project>/<worktree>` (default `~/projects`), and shows an fzf picker if there's more than one.
   - `--watch` means the diff refreshes by itself as files change.
3. **`Ctrl+A`** detaches from an agent session back to the deck.

## Keys

| Key | Where | Action |
|---|---|---|
| `Ctrl+Z` | tmux (no prefix) | Toggle Hunk pane |
| `Alt+←/→/↑/↓` | tmux | Move between panes |
| `Shift+←/→/↑/↓` | tmux | Resize pane |
| `prefix \|` / `prefix -` | tmux | Split right / below (prefix is `Ctrl+B`) |
| `prefix r` | tmux | Reload `~/.tmux.conf` |
| `Ctrl+A` | attached agent-deck session | Detach back to the deck |
| `Ctrl+R` | agent-deck list | Refresh |

## Gotchas

- **`Ctrl+Z` no longer suspends jobs** inside tmux: the hunk binding takes it first.
- **The tmux config doesn't reach agent sessions.** agent-deck runs its sessions on a separate tmux server (`socket_name = "agent-deck"`), so bindings in `~/.tmux.conf` only work in the outer `main` session. That's why you run `agent-deck` inside `main`, and it's what `AGENT_DECK_ALLOW_OUTER_TMUX=1` allows.
- **Hunk shortcuts:** Hunk has a menu bar (`File  View  Navigate  Agent  Help`). Open **Help** to see its key bindings. Click a pane before typing so the keys go to the right pane.
- **macOS clipboard:** `tmux.conf` copies with `xclip`. On a Mac, change `xclip -in -selection clipboard` to `pbcopy` (two lines).
- **`dangerous_mode = true`** in the agent-deck config starts Claude without permission prompts. Remove it if you'd rather approve actions.
