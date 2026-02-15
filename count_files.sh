#!/bin/bash

dirs=("DICOM" "image" "mask")

# Get list of subdirectories from the first directory
mapfile -t subdirs < <(find "${dirs[0]}" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

for sub in "${subdirs[@]}"; do
    counts=()
    for d in "${dirs[@]}"; do
        if [[ ! -d "$d/$sub" ]]; then
            echo "❌ Missing folder: $d/$sub"
            continue 2
        fi
        counts+=("$(find "$d/$sub" -maxdepth 1 -type f | wc -l)")
    done

    if [[ "${counts[0]}" != "${counts[1]}" || "${counts[1]}" != "${counts[2]}" ]]; then
        echo "⚠️ File count mismatch in '$sub': ${counts[*]}"
    else
        echo "✅ '$sub' OK (${counts[0]} files)"
    fi
done
