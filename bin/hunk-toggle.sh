#!/usr/bin/env bash
# Toggle a hunk review pane in the current tmux window.
#
# Repo resolution, in order:
#   1. the calling pane's cwd, if it is a git work tree
#   2. agent-deck session paths that are git repos, plus every checkout under
#      $HUNK_PROJ_ROOT/<project>/<worktree>, picker when more than one
# The agent-deck pane's own cwd is ~, which is not a repo — hence step 2. The
# glob is what surfaces checkouts no agent-deck session points at, such as
# a main checkout; without it the picker only ever lists repos that have a session.
#
# The picker runs in a `tmux display-popup`, not inline: this script is invoked
# from `run-shell`, which has no tty, and fzf there dies with "inappropriate
# ioctl for device" and exits 0 — a silent no-op. The popup supplies the tty.
set -uo pipefail

HUNK_CMD="hunk diff --watch --mode split"
PROJ_ROOT="${HUNK_PROJ_ROOT:-$HOME/projects}"

open_pane() {
  tmux split-window -h -t "$1" -c "$2" "$HUNK_CMD"
}

# Internal re-entry: runs inside the popup, where fzf has a terminal.
if [ "${1:-}" = "--pick" ]; then
  listfile="$2"
  win="$3"
  target=$(fzf --prompt="hunk repo> " < "$listfile")
  rm -f "$listfile"
  [ -z "$target" ] && exit 0
  open_pane "$win" "$target"
  exit 0
fi

PANE_PATH="${1:-$PWD}"
WIN=$(tmux display-message -p '#{window_id}')

existing=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' 2>/dev/null \
           | awk '$2 == "hunk" { print $1; exit }')
if [ -n "$existing" ]; then
  tmux kill-pane -t "$existing"
  exit 0
fi

is_repo() { git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1; }

if is_repo "$PANE_PATH"; then
  open_pane "$WIN" "$PANE_PATH"
  exit 0
fi

mapfile -t candidates < <(
  {
    agent-deck list --json 2>/dev/null \
      | python3 -c 'import sys,json
try: d=json.load(sys.stdin)
except Exception: sys.exit()
rows = d if isinstance(d,list) else d.get("sessions",[])
for s in rows:
    p=(s or {}).get("path","")
    if p: print(p)'
    # <root>/<project>/<worktree>; the unquoted glob leaves itself literal when
    # nothing matches, which the -d test then drops.
    for d in "$PROJ_ROOT"/*/*/; do
      [ -d "$d" ] && printf '%s\n' "${d%/}"
    done
  } | sort -u
)
repos=()
for c in "${candidates[@]:-}"; do
  [ -n "$c" ] && is_repo "$c" && repos+=("$c")
done

case "${#repos[@]}" in
  0)
    tmux display-message "hunk: no git repo found (pane cwd, agent-deck sessions, $PROJ_ROOT)"
    exit 1
    ;;
  1)
    open_pane "$WIN" "${repos[0]}"
    ;;
  *)
    listfile=$(mktemp)
    printf '%s\n' "${repos[@]}" > "$listfile"
    tmux display-popup -E -w 60% -h 40% "'$0' --pick '$listfile' '$WIN'"
    ;;
esac
