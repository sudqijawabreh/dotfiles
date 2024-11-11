#!/bin/sh
URL=$(xclip -o -selection clipboard)
[ -n "$URL" ] && mpv --no-border --geometry=100%x100% --ontop "$URL"
