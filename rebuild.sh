#!/usr/bin/env bash

# For rebuilding Red-Flake
# To run:
#     bash -c "$(curl https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/rebuild.sh)"

# e: Exit script immediately if any command returns a non-zero exit status.
# u: Exit script immediately if an undefined variable is used.
# o pipefail: Ensure Bash pipelines return a non-zero status if any command fails.
set -eou pipefail

# define variables
FLAKE="github:Red-Flake/red-flake-nix"
GIT_REV="main"

# define colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
ENDCOLOR="\e[0m"

function colorprint() {
    local color="$1"
    local text="$2"
    local endcolor="\e[0m"
    echo -e "${color}${text}${endcolor}"
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

# Check for required commands
for cmd in nixos-rebuild; do
    check_command "$cmd"
done

# Network connectivity check
if ! ping -c 1 github.com &> /dev/null; then
    log "ERROR" "Network connectivity check failed. Please ensure you have an active internet connection."
    exit 1
fi

while true; do
    read -rp "Which host to rebuild? (vm / t580) " HOST
    case $HOST in
        vm|t580 ) break;;
        * ) echo "Invalid host. Please select a valid host.";;
    esac
done

log "INFO" "Rebuilding Red-Flake with profile ${HOST}"
sudo nixos-rebuild switch --install-bootloader --flake "${FLAKE}/${GIT_REV:-main}#$HOST" --option eval-cache false

log "INFO" "Rebuilding finished."