#!/usr/bin/env bash

# For rebuilding Red-Flake
# To run:
#     bash -c "$(curl https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/rebuild.sh)"

# e: Exit script immediately if any command returns a non-zero exit status.
# u: Exit script immediately if an undefined variable is used.
# o pipefail: Ensure Bash pipelines return a non-zero status if any command fails.
set -eou pipefail

# define variables
REMOTE_REPO="https://github.com/Red-Flake/red-flake-nix"
GIT_REV="main"
LOCAL_FALLBACK_FLAKE_DIR="/tmp/red-flake-nix"

# define colors
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

function colorprint() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${ENDCOLOR}"
}

function log() {
    local level="$1"
    local message="$2"

    case "$level" in
        "ERROR")
            colorprint "$RED" "[$level] $message"
            ;;
        "INFO")
            colorprint "$BLUE" "[$level] $message"
            ;;
        "WARN")
            colorprint "$YELLOW" "[$level] $message"
            ;;
        *)
            echo "[$level] $message"
            ;;
    esac
}

function check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log "ERROR" "Command not found: $cmd. Please install it and re-run the script."
        exit 1
    fi
}

function resolve_local_flake() {
    local script_dir candidate
    local -a candidates=()

    if [[ -n "${RED_FLAKE_PATH:-}" ]]; then
        candidates+=("${RED_FLAKE_PATH}")
    fi

    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    candidates+=(
        "${script_dir}"
        "${PWD}"
        "${HOME}/Git/red-flake-nix"
        "${HOME}/red-flake-nix"
        "/etc/nixos"
    )

    for candidate in "${candidates[@]}"; do
        if [[ -f "${candidate}/flake.nix" ]]; then
            printf 'path:%s' "${candidate}"
            return 0
        fi
    done

    return 1
}

function prepare_remote_fallback_flake() {
    check_command "git"

    log "INFO" "Cloning Red-Flake into ${LOCAL_FALLBACK_FLAKE_DIR} ..."
    rm -rf "${LOCAL_FALLBACK_FLAKE_DIR}"
    git clone --depth 1 --branch "${GIT_REV}" "${REMOTE_REPO}" "${LOCAL_FALLBACK_FLAKE_DIR}"
    printf 'path:%s' "${LOCAL_FALLBACK_FLAKE_DIR}"
}

# Check for required commands
check_command "nixos-rebuild"

# Prefer a local checkout to avoid fetching the flake on every rebuild.
if FLAKE="$(resolve_local_flake)"; then
    log "INFO" "Using local flake ${FLAKE}"
else
    # Network connectivity check is only required for remote fallback rebuilds.
    if ! ping -c 1 github.com &> /dev/null; then
        log "ERROR" "Network connectivity check failed. Please ensure you have an active internet connection."
        exit 1
    fi

    FLAKE="$(prepare_remote_fallback_flake)"
fi

while true; do
    read -rp "Which host to rebuild? (kvm / vmware / stellaris / vps / redline / borg) " HOST
    case $HOST in
        kvm|vmware|stellaris|vps|redline|borg ) break;;
        * ) echo "Invalid host. Please select a valid host.";;
    esac
done

log "INFO" "Rebuilding Red-Flake with profile ${HOST}"
sudo nixos-rebuild switch --install-bootloader --flake "${FLAKE}#$HOST"

log "INFO" "Rebuilding finished."
