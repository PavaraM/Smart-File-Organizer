#!/bin/bash
# SMART FILE ORGANIZER
# This script organizes files in the specified directory into subdirectories based on their file types.
#------------------------------------------
# VERSION: 2.0
#------------------------------------------

# Log file setup
LOG_FILE="/home/$USER/smart-file-organizer_logs/fixfiles.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Welcome message
echo "Smart File Organizer - Version 2.0"

# Logging start time
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "Script started at: $START_TIME" >> "$LOG_FILE"

# Logging executed command
echo "Executed command: $0 $@" >> "$LOG_FILE"

# Logging user
USER_NAME=$(whoami)
echo "Executed by user: $USER_NAME" >> "$LOG_FILE"

# Logging target directory
echo "Target directory: $1" >> "$LOG_FILE"

# Logging separator
echo "----------------------------------------" >> "$LOG_FILE"

# Set the target directory to the first argument
TARGET_DIR="$1"

# Function to display usage information
usage() {
    echo "Usage: $0 [directory]"
    echo "Organizes files in the specified directory into subdirectories based on file types."
    echo "If no directory is specified, a directory must be provided."
    exit 1
}

# Help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo ""
    usage
fi

# Check if a directory is provided as an argument
if [ $# -gt 1 ]; then
    usage
fi 

# No target directory provided
if [ -z "$TARGET_DIR" ]; then
    echo "Error: No directory specified."
    echo ""
    usage
fi

# Check if the provided argument is a valid directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: $TARGET_DIR is not a valid directory."
    echo ""
    exit 1
fi

# Define file type categories and their corresponding extensions
declare -A FILE_TYPES=(
    ["Images"]="jpg jpeg png gif bmp tiff svg webp heic raw"
    ["Documents"]="pdf doc docx txt xls xlsx ppt pptx odt csv rtf md"
    ["Videos"]="mp4 avi mkv mov wmv flv webm m4v 3gp vob rmvb"
    ["Music"]="mp3 wav flac aac ogg m4a wma"
    ["Archives"]="zip tar gz rar 7z bz2 iso xz cab arj lzma zst"
    ["Scripts"]="sh py js rb pl php bat ps1"
    ["Packages"]="deb rpm dmg exe flatpak appimage"
    ["Executables"]="bin run"
    ["Fonts"]="ttf otf woff woff2"
    ["Code"]="c cpp java cs go rs swift kt"
    ["Config"]="ini cfg conf yml yaml json xml toml"
    ["Logs"]="log"
    ["Backups"]="bak bkp"
    ["Temporary"]="tmp temp"
    ["Torrents"]="torrent"
    ["Profiles"]="profile icc"
    ["Others"]=""
)

# Log directory creation phase
echo "Creating category directories..." >> "$LOG_FILE"

# Create subdirectories for each file type
for TYPE in "${!FILE_TYPES[@]}"; do
    if mkdir -p "$TARGET_DIR/$TYPE" 2>/dev/null; then
        echo "  [✓] Created directory: $TYPE" >> "$LOG_FILE"
    else
        echo "  [✗] Failed to create directory: $TYPE" >> "$LOG_FILE"
    fi
done

echo "----------------------------------------" >> "$LOG_FILE"
echo "Starting file organization..." >> "$LOG_FILE"

# Initialize counters
TOTAL_MOVED=0
TOTAL_ERRORS=0

# Move files to their corresponding subdirectories
shopt -s nullglob
for TYPE in "${!FILE_TYPES[@]}"; do
    for EXT in ${FILE_TYPES[$TYPE]}; do
        for FILE in "$TARGET_DIR"/*.$EXT; do
            if [ -f "$FILE" ]; then
                FILENAME=$(basename "$FILE")
                if mv "$FILE" "$TARGET_DIR/$TYPE/" 2>> "$LOG_FILE"; then
                    echo "  [MOVED] $FILENAME → $TYPE/" >> "$LOG_FILE"
                    ((TOTAL_MOVED++))
                else
                    echo "  [ERROR] Failed to move $FILENAME to $TYPE/" >> "$LOG_FILE"
                    ((TOTAL_ERRORS++))
                fi
            fi
        done
    done
done

# Move files with extensions not listed to "Others"
echo "----------------------------------------" >> "$LOG_FILE"
echo "Moving uncategorized files to Others..." >> "$LOG_FILE"

for FILE in "$TARGET_DIR"/*; do
    if [ -f "$FILE" ]; then
        EXT="${FILE##*.}"
        FOUND=false
        
        for TYPE in "${!FILE_TYPES[@]}"; do
            for TYPE_EXT in ${FILE_TYPES[$TYPE]}; do
                if [[ "$EXT" == "$TYPE_EXT" ]]; then
                    FOUND=true
                    break 2
                fi
            done
        done
        
        if [ "$FOUND" = false ]; then
            FILENAME=$(basename "$FILE")
            if mv "$FILE" "$TARGET_DIR/Others/" 2>> "$LOG_FILE"; then
                echo "  [MOVED] $FILENAME → Others/" >> "$LOG_FILE"
                ((TOTAL_MOVED++))
            else
                echo "  [ERROR] Failed to move $FILENAME to Others/" >> "$LOG_FILE"
                ((TOTAL_ERRORS++))
            fi
        fi
    fi
done

shopt -u nullglob

# Summary
echo "----------------------------------------" >> "$LOG_FILE"
echo "Organization Summary:" >> "$LOG_FILE"
echo "  Total files moved: $TOTAL_MOVED" >> "$LOG_FILE"
echo "  Total errors: $TOTAL_ERRORS" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

# Console output
echo "Files have been organized in $TARGET_DIR."
echo "Total files moved: $TOTAL_MOVED"
if [ $TOTAL_ERRORS -gt 0 ]; then
    echo "Errors encountered: $TOTAL_ERRORS (check log for details)"
fi

# Logging end time
END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "Script ended at: $END_TIME" >> "$LOG_FILE"

# Logging separator
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

exit 0