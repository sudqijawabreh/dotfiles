#!/usr/bin/env bash

set -u

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <search_class> [launch_cmd [args...]]" >&2
    exit 1
fi

SEARCH_CLASS="$1"
shift

if [[ $# -ge 1 ]]; then
    LAUNCH_CMD="$1"
    shift
else
    LAUNCH_CMD="$SEARCH_CLASS"
fi

search_lc="$(printf '%s' "$SEARCH_CLASS" | tr '[:upper:]' '[:lower:]')"

find_hypr_window() {
    hyprctl -j clients 2>/dev/null | jq -r --arg cls "$search_lc" '
        map(select((.class // "" | ascii_downcase | contains($cls))))
        | .[0].address // empty
    '
}

focus_hypr_window() {
    local addr="$1"
    [[ -n "$addr" ]] || return 1
    hyprctl dispatch focuswindow "address:${addr}" >/dev/null 2>&1
}

find_x_window() {
    xdotool search --onlyvisible --class "$SEARCH_CLASS" 2>/dev/null | head -n1
}

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null && command -v jq >/dev/null; then
    if addr="$(find_hypr_window)" && [[ -n "$addr" ]]; then
        focus_hypr_window "$addr" && exit 0
    fi

    nohup "$LAUNCH_CMD" "$@" >/dev/null 2>&1 &

    for _ in {1..50}; do
        if addr="$(find_hypr_window)" && [[ -n "$addr" ]]; then
            focus_hypr_window "$addr" && exit 0
        fi
        sleep 0.1
    done

    echo "Timeout: no Hyprland window appeared for class '$SEARCH_CLASS'" >&2
    exit 1
fi

if command -v xdotool >/dev/null; then
    if win_id="$(find_x_window)" && [[ -n "$win_id" ]]; then
        xdotool windowactivate "$win_id"
        exit 0
    fi

    nohup "$LAUNCH_CMD" "$@" >/dev/null 2>&1 &

    for _ in {1..50}; do
        if win_id="$(find_x_window)" && [[ -n "$win_id" ]]; then
            xdotool windowactivate "$win_id"
            exit 0
        fi
        sleep 0.1
    done

    echo "Timeout: no X11 window appeared for class '$SEARCH_CLASS'" >&2
    exit 1
fi

nohup "$LAUNCH_CMD" "$@" >/dev/null 2>&1 &
