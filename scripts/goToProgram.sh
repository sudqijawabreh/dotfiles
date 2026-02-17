#!/usr/bin/env bash
# goto.sh — focus an existing window by WM_CLASS or launch the program
#
# Usage:
#   goto.sh <search_class> [launch_cmd [args...]]
#
# Examples:
#   # focus or open qutebrowser
#   goto.sh qutebrowser
#
#   # focus a "code" window or open VS Code
#   goto.sh code code --folder-uri ~/projects
#
#   # focus a "firefox" window or open Firefox in private mode
#   goto.sh firefox firefox --private-window https://news.ycombinator.com

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <search_class> [launch_cmd [args...]]" >&2
    exit 1
fi

SEARCH_CLASS="$1"; shift

if [[ $# -ge 1 ]]; then
    LAUNCH_CMD="$1"; shift
else
    LAUNCH_CMD="$SEARCH_CLASS"
fi

_find_window() {
    xdotool search --onlyvisible --class "$SEARCH_CLASS" 2>/dev/null | head -n1
}

# 1) Try to focus existing
if win_id=$(_find_window) && [[ -n "$win_id" ]]; then
    xdotool windowactivate "$win_id"
    exit 0
fi

# 2) Launch in background
nohup "$LAUNCH_CMD" "$@" >/dev/null 2>&1 &

# 3) Wait (up to ~5s) for it to show a window, then focus
for i in {1..50}; do
    if win_id=$(_find_window) && [[ -n "$win_id" ]]; then
        xdotool windowactivate "$win_id"
        exit 0
    fi
    sleep 0.1
done

echo "❌ Timeout: no window appeared for WM_CLASS ‘$SEARCH_CLASS’" >&2
exit 1

