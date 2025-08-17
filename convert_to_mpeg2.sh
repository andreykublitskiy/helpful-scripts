#!/bin/bash

function convert_file() {
    local input_file="$1"
    
    local base_name="$(basename "$input_file")"
    local output_file="${base_name%.*}"
    
    local input_dir="$(dirname "$input_file")"
    local dir_name="$(basename "$input_dir")"
    local output_dir="${input_dir}/${dir_name}"
    
    mkdir -p "$output_dir"
    
ffmpeg -i "$input_file" \
  -threads 0 \
  -vcodec mpeg2video \
  -vf scale=320:-1 \
  -maxrate 1536k \
  -b:v 768 \
  -qmin 3 \
  -qmax 5 \
  -bufsize 4096k \
  -g 300 \
  -c:a mp2 \
  -b:a 128k \
  -ar 44100 \
  -ac 2 \
  "$output_dir/${output_file}.mpg"


}

function convert() {
    echo "Enter directory to search for video files (leave blank for current directory):"
    read -r target_dir
    target_dir="${target_dir:-.}"

    if [ -d "$target_dir" ]; then
        target_dir="$(cd "$target_dir" && pwd)"
    else
        echo "Directory \"$target_dir\" does not exist."
        return 1
    fi

    echo "Enter comma-separated directory names to exclude (leave blank for none):"
    read -r exclude_dirs_input

    # Build find exclude expressions
    exclude_expr=()
    IFS=',' read -ra exclude_dirs <<< "$exclude_dirs_input"
    for dir in "${exclude_dirs[@]}"; do
        dir="$(echo "$dir" | xargs)" # trim whitespace
        if [ -n "$dir" ]; then
            exclude_expr+=( -path "*/$dir" -prune -o )
        fi
    done

    # Build find command dynamically
    if [ ${#exclude_expr[@]} -eq 0 ]; then
        find_cmd=(find "$target_dir" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" \) -print0)
    else
        find_cmd=(find "$target_dir" \( "${exclude_expr[@]}" -false \) -o -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" \) -print0)
    fi

    local files=()
    while IFS= read -r -d $'\0' file; do
        files+=("$file")
    done < <("${find_cmd[@]}")

    if [ ${#files[@]} -eq 0 ]; then
        echo "No video files found in \"$target_dir\" or its subdirectories (after exclusions)."
        return 1
    fi

    for input_file in "${files[@]}"; do
        echo "Converting $input_file..."
        convert_file "$input_file"
    done
}

echo "Convert:"
echo "  1) A specific file"
echo "  2) All files in a directory"
read -r option

if [ "$option" == "1" ]; then
    echo "Enter the name of the file:"
    read -r input_file
    if [ ! -f "$input_file" ]; then
        echo "File \"$input_file\" does not exist."
        exit 1
    fi
    convert_file "$input_file"
elif [ "$option" == "2" ]; then
    convert
else
    echo "Invalid option selected"
    exit 1
fi
