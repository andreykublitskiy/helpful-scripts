#!/bin/bash

terminate_process() {
  local process_name=$1
  local process_id=$(pgrep "$process_name")

  if [[ -n "$process_id" ]]; then
    # Force quit the process
    kill -9 "$process_id"
    echo "$process_name process terminated."
  else
    echo "$process_name process not found."
  fi
}

# Terminate both processes
terminate_process "WallpaperVideoExtension"
terminate_process "WallpaperImageExtension"
