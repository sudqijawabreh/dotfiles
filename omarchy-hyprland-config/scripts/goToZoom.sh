#!/usr/bin/env bash

set -u

if [[ $# -ge 1 ]]; then
    LAUNCH_CMD="$1"
    shift
else
    LAUNCH_CMD="zoom"
fi

find_hypr_zoom_meeting() {
    hyprctl -j clients 2>/dev/null | jq -r '
        map(select(
            (.class // "" | ascii_downcase | contains("zoom"))
            and
            (.title // "" | ascii_downcase | contains("meeting"))
        ))
        | .[0].address // empty
    '
}

find_hypr_zoom_any() {
    hyprctl -j clients 2>/dev/null | jq -r '
        map(select((.class // "" | ascii_downcase | contains("zoom"))))
        | .[0].address // empty
    '
}

focus_hypr_window() {
    local addr="$1"
    [[ -n "$addr" ]] || return 1
    hyprctl dispatch focuswindow "address:${addr}" >/dev/null 2>&1
}

find_x_zoom_meeting() {
    xdotool search --class "zoom" 2>/dev/null | while read -r window_id; do
        if xdotool getwindowname "$window_id" | grep -qi "Meeting"; then
            echo "$window_id"
            break
        fi
    done
}

find_x_zoom_any() {
    xdotool search --class "zoom" 2>/dev/null | head -n1
}

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null && command -v jq >/dev/null; then
    if addr="$(find_hypr_zoom_meeting)" && [[ -n "$addr" ]]; then
        focus_hypr_window "$addr" && exit 0
    fi
    if addr="$(find_hypr_zoom_any)" && [[ -n "$addr" ]]; then
        focus_hypr_window "$addr" && exit 0
    fi

    nohup "$LAUNCH_CMD" "$@" >/dev/null 2>&1 &
    for _ in {1..50}; do
        if addr="$(find_hypr_zoom_meeting)" && [[ -n "$addr" ]]; then
            focus_hypr_window "$addr" && exit 0
        fi
        if addr="$(find_hypr_zoom_any)" && [[ -n "$addr" ]]; then
            focus_hypr_window "$addr" && exit 0
        fi
        sleep 0.1
    done
    exit 0
fi

if command -v xdotool >/dev/null; then
    if win_id="$(find_x_zoom_meeting)" && [[ -n "$win_id" ]]; then
        xdotool windowactivate "$win_id"
        exit 0
    fi
    if win_id="$(find_x_zoom_any)" && [[ -n "$win_id" ]]; then
        xdotool windowactivate "$win_id"
        exit 0
    fi

    nohup "$LAUNCH_CMD" "$@" >/dev/null 2>&1 &
    for _ in {1..50}; do
        if win_id="$(find_x_zoom_meeting)" && [[ -n "$win_id" ]]; then
            xdotool windowactivate "$win_id"
            exit 0
        fi
        if win_id="$(find_x_zoom_any)" && [[ -n "$win_id" ]]; then
            xdotool windowactivate "$win_id"
            exit 0
        fi
        sleep 0.1
    done
    exit 0
fi

nohup "$LAUNCH_CMD" "$@" >/dev/null 2>&1 &
