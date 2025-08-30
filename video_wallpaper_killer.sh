#!/bin/bash
process=$(pgrep WallpaperVideoExtension)

if [[ -n "$process" ]]; then

# Force quit the process
kill -9 "$process"
echo "WallpaperVideoExtension process terminated."
else
echo "WallpaperVideoExtension process not found."
fi

process2=$(pgrep WallpaperImageExtension)

if [[ -n "$process2" ]]; then

# Force quit the process2
kill -9 "$process2"
echo "WallpaperImageExtension process terminated."
else
echo "WallpaperImageExtension process not found."
fi
