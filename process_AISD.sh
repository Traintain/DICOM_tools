#!/usr/bin/env bash

set -u  # fail on undefined variables (but NOT on errors)

BASE="/home/juanma/Documents/AISD/DICOM"
LOG_BAD="$BASE/corrupted_archives.log"
LOG_TAR="$BASE/tar_errors.log"

echo "Starting processing..."
echo "Logs:"
echo "  Corrupted: $LOG_BAD"
echo "  Tar errors: $LOG_TAR"
echo

# ---- STEP 1: Extract all archives safely ----
find "$BASE"/dicom-* -name "*.tar.gz" | while read -r f; do
    echo "Processing archive: $f"

    # Check gzip integrity
    if gzip -t "$f" 2>/dev/null; then
        tar -xzf "$f" -C "$(dirname "$f")" 2>>"$LOG_TAR" || {
            echo "TAR FAILED: $f" >> "$LOG_TAR"
            continue
        }

        # Optional: remove archive after successful extraction
        # rm "$f"

    else
        echo "GZIP FAILED (corrupted): $f" >> "$LOG_BAD"
        continue
    fi
done

echo "Extraction phase completed."
echo

# ---- STEP 2: Move CT files to final structure ----
for parent in "$BASE"/dicom-*; do
    [ -d "$parent" ] || continue

    for dir in "$parent"/*; do
        id=$(basename "$dir")
        src="$dir/CT"
        dst="$BASE/$id"

        if [ -d "$src" ]; then
            echo "Moving CT for study $id"
            mkdir -p "$dst"
            mv "$src"/* "$dst"/ 2>/dev/null
        fi
    done
done

echo
echo "Move phase completed."

# ---- STEP 3: Summary ----
echo
echo "Summary:"
[ -f "$LOG_BAD" ] && echo "Corrupted archives: $(wc -l < "$LOG_BAD")"
[ -f "$LOG_TAR" ] && echo "Tar errors: $(wc -l < "$LOG_TAR")"

echo "Done."

