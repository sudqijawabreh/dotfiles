#!/bin/bash

# Check if URL is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <YouTube Playlist URL>"
    exit 1
fi

# Check for --no-video argument
if [[ "$2" == "--no-video" ]]; then
    MPV_OPTIONS="--ytdl-format=bestaudio --no-video"
fi
# Extract playlist URLs with yt-dlp and pipe to mpv
# Extract playlist and play with MPV
yt-dlp --flat-playlist -J "$1" | jq -r '.entries[].url' | mpv $MPV_OPTIONS --playlist=-
#yt-dlp --flat-playlist -J "https://www.youtube.com/watch?v=X-yIEMduRXk&list=RDQM-cupWYO-gLU&start_radio=1" | jq -r '.entries[].url' | mpv --playlist=-
