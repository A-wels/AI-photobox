#!/bin/bash

if [ -z "$3" ]; then
    echo "usage: $0 background.png foreground.png output.png"
    exit 1
fi

bg_size=$(identify -format '%wx%h' "$1")
tmp_fg=$(mktemp "/tmp/foreground_tmp_XXXXXX.png")

# Scale the foreground to the same size as the background
convert "$2" -resize $bg_size\! "$tmp_fg"

# Composite the background and scaled foreground, preserving transparency
convert -size $bg_size -composite "$1" "$tmp_fg" -geometry $bg_size+0+5 -depth 8 "$3"

# Clean up temporary files
rm "$tmp_fg"
