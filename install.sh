#!/usr/bin/env bash
# Smart File Organizer — installation script
# Version: 2.0.0
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────
# DESTDIR is the standard way to support staged installs (package builds)
DESTDIR="${DESTDIR:-}"
PREFIX="${PREFIX:-/usr/local}"
INSTALL_DIR="${DESTDIR}${PREFIX}/bin"
LOG_DIR="${HOME}/smart-file-organizer_logs"
SCRIPT_NAME="fixfolder"
UNINSTALL_NAME="fixfolder-uninstall"

# Colours (only when connected to a terminal)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

info()  { printf "%b%s%b\n" "${GREEN}✓${NC}" "$1" "${NC}"; }
warn()  { printf "%b%s%b\n" "${YELLOW}⚠${NC}" "$1" "${NC}"; }
error() { printf "%b%s%b\n" "${RED}✗${NC}" "$1" "${NC}" >&2; }
header(){ printf "%b%s%b\n" "${BLUE}" "$1" "${NC}"; }

# ── Detect install scope ─────────────────────────────────────────────
detect_install_scope() {
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
        echo "system"
    else
        echo "user"
    fi
}

resolve_install_dir() {
    local scope="$1"
    if [[ "$scope" == "user" ]]; then
        INSTALL_DIR="${DESTDIR}${HOME}/.local/bin"
    fi
    echo "$INSTALL_DIR"
}

# ── Install main script ──────────────────────────────────────────────
install_fixfolder() {
    local target="$1/fixfolder"

    if [[ ! -f "fixfolder.sh" ]]; then
        error "fixfolder.sh not found in current directory"
        exit 1
    fi

    install -m 755 fixfolder.sh "$target"
    info "Installed fixfolder to ${target}"
}

# ── Create log directory ─────────────────────────────────────────────
setup_log_dir() {
    mkdir -p "$LOG_DIR"
    info "Log directory: ${LOG_DIR}"
}

# ── PATH setup ───────────────────────────────────────────────────────
setup_path() {
    local install_dir="$1"
    local rc_file=""

    if [[ ":$PATH:" == *":${install_dir}:"* ]]; then
        info "${install_dir} is already in PATH"
        return
    fi

    warn "${install_dir} is not in PATH"

    # Determine shell RC
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        rc_file="${ZDOTDIR:-$HOME}/.zshrc"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
            [[ -f "$f" ]] && { rc_file="$f"; break; }
        done
    fi
    : "${rc_file:="$HOME/.profile"}"

    if ! grep -qF "$install_dir" "$rc_file" 2>/dev/null; then
        {
            echo ""
            echo "# Smart File Organizer"
            echo "export PATH=\"\$PATH:${install_dir}\""
        } >> "$rc_file"
        info "Added ${install_dir} to ${rc_file}"
        warn "Run: source ${rc_file}"
    fi
}

# ── Create uninstaller ───────────────────────────────────────────────
create_uninstaller() {
    local target="$1/${UNINSTALL_NAME}"
    local install_dir="$1"
    local log_dir="$LOG_DIR"

    cat > "$target" <<UNINSTALL_EOF
#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX}"
INSTALL_DIR="${install_dir}"
LOG_DIR="${log_dir}"

echo "Uninstalling Smart File Organizer..."

# Remove main script
rm -f "\${INSTALL_DIR}/fixfolder"
echo "  Removed \${INSTALL_DIR}/fixfolder"

# Remove self
rm -f "\${INSTALL_DIR}/${UNINSTALL_NAME}"
echo "  Removed \${INSTALL_DIR}/${UNINSTALL_NAME}"

echo ""
echo "Uninstall complete."
echo "Log files preserved at: \${LOG_DIR}"
echo "To remove logs: rm -rf \${LOG_DIR}"
UNINSTALL_EOF

    chmod 755 "$target"
    info "Uninstall script: ${target}"
}

# ── Main ──────────────────────────────────────────────────────────────
main() {
    header "========================================"
    header "Smart File Organizer — Installation"
    header "========================================"
    echo ""

    local scope
    scope="$(detect_install_scope)"
    local install_dir
    install_dir="$(resolve_install_dir "$scope")"

    echo "  Mode:          $scope-wide"
    echo "  Install dir:   $install_dir"
    echo "  Log dir:       $LOG_DIR"
    echo ""

    mkdir -p "$install_dir"
    install_fixfolder "$install_dir"
    setup_log_dir
    create_uninstaller "$install_dir"

    if [[ "$scope" == "user" ]]; then
        setup_path "$install_dir"
    fi

    echo ""
    header "========================================"
    header "Installation Complete!"
    header "========================================"
    echo ""
    echo "  Run:  fixfolder /path/to/directory"
    echo "  Help: fixfolder --help"
    echo "  Logs: ${LOG_DIR}/fixfiles.log"
    echo ""

    if [[ "$scope" == "user" ]]; then
        warn "Restart your terminal or run: source ~/.bashrc"
        echo ""
    fi
}

main "$@"
