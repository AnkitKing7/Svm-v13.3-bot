#!/usr/bin/env bash
# ============================================================
#  SVM V13.3 BOT - GITHUB BOOTSTRAP INSTALLER
#  Made with <3 by AnkitCoder
#
#  Keep this file beside: Svm-v13.3-bot.zip
#  Run: chmod +x install.sh && ./install.sh
# ============================================================

set -Eeuo pipefail

APP_NAME="SVM V13.3 BOT"
APP_VERSION="13.3"
AUTHOR="AnkitCoder"
ZIP_NAME="Svm-v13.3-bot.zip"
PROJECT_DIR="Svm-v13.3-bot"
LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/bootstrap-install-$(date +%Y%m%d-%H%M%S).log"

# ---------- Terminal colors ----------
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_CYAN=$'\033[1;36m'
  C_BLUE=$'\033[1;34m'
  C_PURPLE=$'\033[1;35m'
  C_GREEN=$'\033[1;32m'
  C_YELLOW=$'\033[1;33m'
  C_RED=$'\033[1;31m'
  C_WHITE=$'\033[1;37m'
else
  C_RESET='' C_BOLD='' C_CYAN='' C_BLUE='' C_PURPLE=''
  C_GREEN='' C_YELLOW='' C_RED='' C_WHITE=''
fi

# ---------- Helpers ----------
banner() {
  clear 2>/dev/null || true
  printf '%s\n' "${C_PURPLE}╔══════════════════════════════════════════════════════════════════════╗"
  printf '%s\n' "║                                                                      ║"
  printf '%s\n' "║   ███████╗██╗   ██╗███╗   ███╗    ██╗   ██╗ ██╗██████╗               ║"
  printf '%s\n' "║   ██╔════╝██║   ██║████╗ ████║    ██║   ██║███║██╔══██╗              ║"
  printf '%s\n' "║   ███████╗██║   ██║██╔████╔██║    ██║   ██║╚██║██████╔╝              ║"
  printf '%s\n' "║   ╚════██║██║   ██║██║╚██╔╝██║    ╚██╗ ██╔╝ ██║██╔══██╗              ║"
  printf '%s\n' "║   ███████║╚██████╔╝██║ ╚═╝ ██║     ╚████╔╝  ██║██████╔╝              ║"
  printf '%s\n' "║   ╚══════╝ ╚═════╝ ╚═╝     ╚═╝      ╚═══╝   ╚═╝╚═════╝               ║"
  printf '%s\n' "║                                                                      ║"
  printf '%s\n' "║                    ${C_WHITE}V13.3 BOT INSTALLER${C_PURPLE}                         ║"
  printf '%s\n' "║                                                                      ║"
  printf '%s\n' "║                 ${C_CYAN}MADE WITH <3 BY ANKITCODER${C_PURPLE}                       ║"
  printf '%s\n' "║                                                                      ║"
  printf '%s\n' "╚══════════════════════════════════════════════════════════════════════╝${C_RESET}"
  printf '\n%s\n' "${C_CYAN}${C_BOLD}      VPS • KVM • IPAM • NETWORK • AUTOMATION${C_RESET}"
  printf '%s\n\n' "${C_BLUE}      GitHub ZIP • Automatic Setup • Bootstrap Installer${C_RESET}"
}

info()    { printf '%s[INFO]%s %s\n' "$C_CYAN" "$C_RESET" "$*"; }
success() { printf '%s[ OK ]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()    { printf '%s[WARN]%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
fail()    { printf '%s[FAIL]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

step() {
  printf '\n%s┌─ [%s] %s%s\n' "$C_PURPLE" "$1" "$2" "$C_RESET"
}

on_error() {
  local exit_code=$?
  fail "Installation stopped at line ${BASH_LINENO[0]:-unknown} (exit ${exit_code})."
  if [[ -f "$LOG_FILE" ]]; then
    warn "Bootstrap log: $LOG_FILE"
  fi
  exit "$exit_code"
}
trap on_error ERR

# ---------- Start ----------
banner
mkdir -p "$LOG_DIR"
# Keep a readable log while still showing output in the terminal.
exec > >(tee -a "$LOG_FILE") 2>&1

info "Starting ${APP_NAME} v${APP_VERSION}"
info "Installer author: ${AUTHOR}"
info "Working directory: $(pwd)"
info "Log file: ${LOG_FILE}"

if [[ "${EUID}" -ne 0 ]]; then
  fail "Root privileges are required."
  echo "Run: sudo bash install.sh"
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  fail "This bootstrap installer requires an Ubuntu/Debian system with apt-get."
  exit 1
fi

if [[ ! -f "$ZIP_NAME" ]]; then
  fail "Cannot find ${ZIP_NAME} in: $(pwd)"
  echo "Place install.sh and ${ZIP_NAME} in the same directory."
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  warn "systemctl was not found. The project's installer may need a systemd-based host."
fi

# ---------- Package setup ----------
step "1/5" "Updating Ubuntu/Debian package indexes"
export DEBIAN_FRONTEND=noninteractive
apt-get update
success "Package indexes updated"

step "2/5" "Installing required archive utility"
apt-get install -y unzip
success "unzip is installed"

# ---------- Archive validation ----------
step "3/5" "Checking project ZIP"
if ! unzip -tq "$ZIP_NAME" >/dev/null; then
  fail "The ZIP archive is damaged or invalid: ${ZIP_NAME}"
  exit 1
fi
success "ZIP archive integrity check passed"

# ---------- Extraction ----------
step "4/5" "Extracting project files"
mkdir -p "$PROJECT_DIR"
unzip -oq "$ZIP_NAME" -d "$PROJECT_DIR"

INNER_INSTALLER="${PROJECT_DIR}/install.sh"
if [[ ! -f "$INNER_INSTALLER" ]]; then
  fail "Expected installer not found: ${INNER_INSTALLER}"
  echo "The ZIP must contain install.sh at its root after extraction."
  echo "Inspect the archive layout before retrying."
  exit 1
fi
chmod +x "$INNER_INSTALLER"
success "Project extracted to $(pwd)/${PROJECT_DIR}"

# ---------- Launch original project installer ----------
step "5/5" "Launching SVM V13.3 project installer"
echo
printf '%s\n' "${C_GREEN}╔══════════════════════════════════════════════════════════════╗"
printf '%s\n' "║                 BOOTSTRAP COMPLETED                          ║"
printf '%s\n' "║          Starting the original project setup now            ║"
printf '%s\n' "╚══════════════════════════════════════════════════════════════╝${C_RESET}"
echo

cd "$PROJECT_DIR"
exec bash ./install.sh
