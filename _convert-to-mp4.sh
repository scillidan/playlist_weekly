#!/bin/bash
# Authors: DeepSeek🧙‍♂️, scillidan🤡

# Configuration
AUDIO_BITRATE="256k"
OUTPUT_DIR="converted_videos"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Counters
processed=0
skipped=0
errors=0

# Store find results in array to avoid subshell issues
jpg_files=()
while IFS= read -r -d '' file; do
    jpg_files+=("$file")
done < <(find . -type f -name "*.pdf.jpg" -print0)

echo "Found ${#jpg_files[@]} PDF image files"

# Process each file
for jpg_file in "${jpg_files[@]}"; do
    base_name="${jpg_file%.pdf.jpg}"
    mp3_file="${base_name}.mp3"
    filename=$(basename "$jpg_file" .pdf.jpg)
    mp4_file="${OUTPUT_DIR}/${filename}.mp4"

    echo "Processing: $filename"

    if [[ -f "$mp3_file" ]]; then
        echo "Found audio: $(basename "$mp3_file")"
        echo "Output video: $(basename "$mp4_file")"

        # FFmpeg command with modifications:
        # 1. Use -loop 1 to loop the image
        # 2. Set -framerate 1 for static image (low frame rate)
        # 3. -c:v libx264 for video encoding
        # 4. -c:a copy to copy audio stream without re-encoding
        # 5. -shortest to match audio duration
        # 6. No scaling, keep original image dimensions
        # 7. -pix_fmt yuv420p for compatibility
        ffmpeg -loop 1 -framerate 1 -i "$jpg_file" -i "$mp3_file" \
            -c:v libx264 -tune stillimage -c:a copy \
            -pix_fmt yuv420p \
            -shortest -y "$mp4_file"

        if [[ $? -eq 0 ]]; then
            echo "Conversion successful: $(basename "$mp4_file")"
            ((processed++))
        else
            echo "Conversion failed: $(basename "$mp4_file")"
            ((errors++))
        fi
    else
        echo "Audio file not found: $(basename "$mp3_file")"
        ((skipped++))
    fi

    echo
done

# Print summary
echo "================================"
echo "Processing complete!"
echo "Successfully processed: $processed files"
echo "Skipped: $skipped files (no audio)"
echo "Failed: $errors files"