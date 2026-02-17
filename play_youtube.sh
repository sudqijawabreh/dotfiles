#!/bin/sh
URL=$(xclip -o -selection clipboard)
[ -n "$URL" ] && prime-run mpv --no-border --geometry=100%x100% --ontop "$URL"
