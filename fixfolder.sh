#!/usr/bin/env bash
# Smart File Organizer — automatically sorts files into categorized folders
# Version: 3.0.0
set -euo pipefail

# ── Config (overridable via environment) ──────────────────────────────
SFO_LOG_DIR="${SFO_LOG_DIR:-"${HOME}/smart-file-organizer_logs"}"
SFO_DRY_RUN="${SFO_DRY_RUN:-false}"
SFO_VERBOSE="${SFO_VERBOSE:-false}"
SFO_QUIET="${SFO_QUIET:-false}"

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly VERSION="3.0.0"

# ── File-type map ─────────────────────────────────────────────────────
declare -A FILE_TYPES=(
    [Images]="jpg jpeg png gif bmp tiff svg webp heic raw"
    [Documents]="pdf doc docx txt xls xlsx ppt pptx odt csv rtf md"
    [Videos]="mp4 avi mkv mov wmv flv webm m4v 3gp vob rmvb"
    [Music]="mp3 wav flac aac ogg m4a wma"
    [Archives]="zip tar gz rar 7z bz2 iso xz cab arj lzma zst"
    [Scripts]="sh py js rb pl php bat ps1"
    [Packages]="deb rpm dmg exe flatpak appimage"
    [Executables]="bin run"
    [Fonts]="ttf otf woff woff2"
    [Code]="c cpp java cs go rs swift kt"
    [Config]="ini cfg conf yml yaml json xml toml"
    [Logs]="log"
    [Backups]="bak bkp"
    [Temporary]="tmp temp"
    [Torrents]="torrent"
    [Profiles]="profile icc"
)

# ── Helpers ───────────────────────────────────────────────────────────
log() {
    local level="$1" msg="$2"
    local ts
    ts="$(date +"%Y-%m-%d %H:%M:%S")"
    echo "[${ts}] [${level}] ${msg}" >> "$LOG_FILE"
}

die() {
    echo "$SCRIPT_NAME: error: $*" >&2
    exit 1
}

info() {
    if [[ "$SFO_QUIET" != "true" ]]; then
        printf "%s\n" "$*"
    fi
}

verbose() {
    if [[ "$SFO_VERBOSE" == "true" ]]; then
        printf "%s\n" "$*" >&2
    fi
}

usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <directory>

Organise files in <directory> into categorised subdirectories.

Options:
  -n, --dry-run      Show what would be moved without actually moving
  -v, --verbose      Enable verbose logging to stderr
  -q, --quiet        Suppress stdout output
  -l, --log-dir DIR  Set custom log directory (default: ~/smart-file-organizer_logs)
  -h, --help         Show this help message and exit

Environment variables:
  SFO_DRY_RUN=true   Equivalent to --dry-run
  SFO_LOG_DIR=path   Equivalent to --log-dir
  SFO_VERBOSE=true   Equivalent to --verbose
  SFO_QUIET=true     Equivalent to --quiet

Examples:
  ${SCRIPT_NAME} ~/Downloads
  ${SCRIPT_NAME} --dry-run ~/Downloads
  ${SCRIPT_NAME} --verbose --log-dir /var/log ~/Downloads

Exit codes:
  0  Success
  1  Error
  2  Usage / invalid argument
EOF
    exit 0
}

create_log_file() {
    mkdir -p "$SFO_LOG_DIR"
    LOG_FILE="${SFO_LOG_DIR}/fixfiles.log"
    : > "$LOG_FILE"
    log "INFO" "=== Smart File Organizer v${VERSION} ==="
    log "INFO" "Command: ${SCRIPT_NAME} $*"
    log "INFO" "User: $(whoami)"
    log "INFO" "Dry-run: ${SFO_DRY_RUN}"
}

create_category_dirs() {
    local target="$1"
    log "INFO" "Creating category directories in ${target}"
    for type in "${!FILE_TYPES[@]}"; do
        if [[ "$SFO_DRY_RUN" == "true" ]]; then
            verbose "[DRY-RUN] Would create directory: ${target}/${type}"
        else
            mkdir -p "${target}/${type}"
            log "INFO" "Created directory: ${type}"
        fi
    done
}

move_files_for_type() {
    local target="$1" type="$2" ext="$3" moved=0 errors=0

    if [[ "$SFO_DRY_RUN" == "true" ]]; then
        for file in "${target}"/*."${ext}"; do
            [[ -f "$file" ]] || continue
            local fname
            fname="$(basename "$file")"
            verbose "[DRY-RUN] Would move: ${fname} -> ${type}/"
            ((moved++)) || true
        done
    else
        shopt -s nullglob
        for file in "${target}"/*."${ext}"; do
            [[ -f "$file" ]] || continue
            local fname
            fname="$(basename "$file")"
            if mv "$file" "${target}/${type}/" 2>> "$LOG_FILE"; then
                log "INFO" "[MOVED] ${fname} -> ${type}/"
                ((moved++)) || true
            else
                log "ERROR" "Failed to move ${fname} -> ${type}/"
                ((errors++)) || true
            fi
        done
        shopt -u nullglob
    fi

    echo "$moved $errors"
}

organize_by_category() {
    local target="$1"
    local total_moved=0 total_errors=0

    log "INFO" "Starting file organisation"

    for type in "${!FILE_TYPES[@]}"; do
        for ext in ${FILE_TYPES[$type]}; do
            read -r moved errors < <(move_files_for_type "$target" "$type" "$ext")
            ((total_moved += moved)) || true
            ((total_errors += errors)) || true
        done
    done

    echo "$total_moved $total_errors"
}

organize_others() {
    local target="$1" moved=0 errors=0 others_dir="${target}/Others"

    log "INFO" "Moving uncategorised files to Others/"

    if [[ "$SFO_DRY_RUN" == "true" ]]; then
        shopt -s nullglob
        for file in "${target}"/*; do
            [[ -f "$file" ]] || continue
            local ext fname found=false
            fname="$(basename "$file")"
            ext="${fname##*.}"

            for type in "${!FILE_TYPES[@]}"; do
                for type_ext in ${FILE_TYPES[$type]}; do
                    if [[ "$ext" == "$type_ext" ]]; then
                        found=true
                        break 2
                    fi
                done
            done

            if [[ "$found" == false ]]; then
                verbose "[DRY-RUN] Would move: ${fname} -> Others/"
                ((moved++)) || true
            fi
        done
        shopt -u nullglob
    else
        mkdir -p "$others_dir"
        shopt -s nullglob
        for file in "${target}"/*; do
            [[ -f "$file" ]] || continue
            local ext fname found=false
            fname="$(basename "$file")"
            ext="${fname##*.}"

            for type in "${!FILE_TYPES[@]}"; do
                for type_ext in ${FILE_TYPES[$type]}; do
                    if [[ "$ext" == "$type_ext" ]]; then
                        found=true
                        break 2
                    fi
                done
            done

            if [[ "$found" == false ]]; then
                if mv "$file" "$others_dir/" 2>> "$LOG_FILE"; then
                    log "INFO" "[MOVED] ${fname} -> Others/"
                    ((moved++)) || true
                else
                    log "ERROR" "Failed to move ${fname} -> Others/"
                    ((errors++)) || true
                fi
            fi
        done
        shopt -u nullglob
        rmdir "$others_dir" 2>/dev/null || true
    fi

    echo "$moved $errors"
}

print_summary() {
    local moved="$1" errors="$2"

    if [[ "$SFO_DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Would move ${moved} file(s)"
        return
    fi

    info "Files have been organised."
    info "Total files moved: ${moved}"
    if (( errors > 0 )); then
        info "Errors encountered: ${errors} (check log for details)"
    fi
}

# ── CLI argument parsing ──────────────────────────────────────────────
parse_args() {
    local args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            -n|--dry-run)
                SFO_DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                SFO_VERBOSE=true
                shift
                ;;
            -q|--quiet)
                SFO_QUIET=true
                shift
                ;;
            -l|--log-dir)
                if [[ -z "${2:-}" ]]; then
                    die "--log-dir requires a directory path"
                fi
                SFO_LOG_DIR="$2"
                shift 2
                ;;
            --log-dir=*)
                SFO_LOG_DIR="${1#*=}"
                shift
                ;;
            -*)
                echo "$SCRIPT_NAME: unknown flag: $1" >&2
                echo "Try '$SCRIPT_NAME --help' for usage." >&2
                exit 2
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#args[@]} -gt 1 ]]; then
        echo "$SCRIPT_NAME: too many arguments" >&2
        echo "Try '$SCRIPT_NAME --help' for usage." >&2
        exit 2
    fi

    TARGET_DIR="${args[0]:-}"
}

# ── Main ──────────────────────────────────────────────────────────────
main() {
    parse_args "$@"

    if [[ -z "$TARGET_DIR" ]]; then
        echo "$SCRIPT_NAME: no directory specified" >&2
        echo "Try '$SCRIPT_NAME --help' for usage." >&2
        exit 2
    fi

    if [[ ! -d "$TARGET_DIR" ]]; then
        die "${TARGET_DIR} is not a valid directory"
    fi

    # Resolve to absolute path
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

    create_log_file "$@"
    info "Smart File Organizer - Version ${VERSION}"
    verbose "Target: ${TARGET_DIR}"

    create_category_dirs "$TARGET_DIR"

    read -r total_moved total_errors < <(organize_by_category "$TARGET_DIR")
    read -r others_moved others_errors < <(organize_others "$TARGET_DIR")

    total_moved=$((total_moved + others_moved))
    total_errors=$((total_errors + others_errors))

    log "INFO" "Organisation complete: ${total_moved} moved, ${total_errors} errors"

    print_summary "$total_moved" "$total_errors"

    exit 0
}

main "$@"
