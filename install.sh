#!/usr/bin/env bash

# For installing NixOS having booted from the minimal USB image.
# To run:
#     bash -c "$(curl https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/install.sh)"

# e: Exit script immediately if any command returns a non-zero exit status.
# u: Exit script immediately if an undefined variable is used.
# o pipefail: Ensure Bash pipelines return a non-zero status if any command fails.
set -eou pipefail

# make sure this script is run as root (sudo does not work)
if [ "$(id -u)" -ne 0 ]; then
    printf "This script has to run as root (do not use sudo)\n" >&2
    exit 1
elif [ -n "${SUDO_USER:-}" ]; then
    printf "This script has to run as root (not sudo)\n" >&2
    exit 1
fi

# define variables
LOGFILE="/mnt/nixos_install.log"
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

function yesno() {
    local prompt="$1"
    while true; do
        read -rp "$prompt [y/n] " yn
        case $yn in
            [Yy]* ) echo "y"; return;;
            [Nn]* ) echo "n"; return;;
            * ) log "INFO" "Please answer yes or no.";;
        esac
    done
}

log "INFO" "Welcome to the Red Flake installer!"
log "INFO" "The installer will log the installation process to $LOGFILE."

log "INFO" "This script will format the *entire* disk with a 1GB boot partition
(labelled NIXBOOT), 16GB of swap, then allocating the rest to ZFS.

The following ZFS datasets will be created:
    - zroot/root (mounted at / with blank snapshot)
    - zroot/nix (mounted at /nix)
    - zroot/tmp (mounted at /tmp)
    - zroot/persist (mounted at /persist)
    - zroot/persist/cache (mounted at /persist/cache)"

# Check for required commands
for cmd in blkdiscard sgdisk zpool zfs mkfs.fat mkswap swapon; do
    check_command "$cmd"
done

# Network connectivity check
if ! ping -c 1 github.com &> /dev/null; then
    log "ERROR" "Network connectivity check failed. Please ensure you have an active internet connection."
    exit 1
fi

# Check if in a VM
if [[ -b "/dev/vda" ]]; then
    log "INFO" "VM was detected!"

    DISK="/dev/vda"

    do_format=$(yesno "Will now install Red-Flake to ${DISK}. This irreversibly formats the entire disk. Are you sure?")
    if [[ $do_format == "n" ]]; then
        exit
    fi

    BOOTDISK="${DISK}3"
    SWAPDISK="${DISK}2"
    ZFSDISK="${DISK}1"
else
    log "INFO" "Your attached storage devices will now be listed."
    read -p "Press enter to continue." NULL

    printf "\n"

    log "INFO" "Detected the following devices:"
    lsblk

    printf "\n"

    read -p "Which device do you wish to install on? " DISKINPUT
    DISK="/dev/${DISKINPUT}"

    if [ ! -b "$DISK" ]; then
        log "ERROR" "Device $DISK does not exist."
        exit 1
    fi

    BOOTDISK="${DISK}p3"
    SWAPDISK="${DISK}p2"
    ZFSDISK="${DISK}p1"

    log "INFO" "Boot Partition: $BOOTDISK"
    log "INFO" "SWAP Partition: $SWAPDISK"
    log "INFO" "ZFS Partition: $ZFSDISK"

    do_format=$(yesno "Will now install Red-Flake to ${DISK}. This irreversibly formats the entire disk. Are you sure?")
    if [[ $do_format == "n" ]]; then
        exit
    fi
fi

sgdisk -p "$DISK" > /dev/null

log "INFO" "Erasing disk ${DISK} ..."
blkdiscard -f "$DISK"

log "INFO" "Clear partition table on disk ${DISK} ..."
sgdisk --zap-all "$DISK"

log "INFO" "Creating new GPT partition table on disk ${DISK} ..."
sgdisk -o "$DISK"

sgdisk -p "$DISK" > /dev/null

log "INFO" "Creating partitions on disk ${DISK} ..."
sgdisk -n3:1M:+1G -t3:EF00 "$DISK"

sgdisk -n2:0:+16G -t2:8200 "$DISK"

sgdisk -n1:0:0 -t1:BF01 "$DISK"

log "INFO" "Notifying kernel of partition changes..."
sgdisk -p "$DISK" > /dev/null
sleep 5

log "INFO" "Creating Swap"
mkswap "$SWAPDISK" --label "SWAP"

swapon "$SWAPDISK"

log "INFO" "Creating Boot Disk"
mkfs.vfat "$BOOTDISK" -n NIXBOOT

use_encryption=$(yesno "Use encryption? (Encryption must also be enabled within host config.)")
if [[ $use_encryption == "y" ]]; then
    encryption_options=(-O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt)
else
    encryption_options=()
fi

log "INFO" "Creating base zpool on disk ${ZFSDISK} ..."
zpool create -f \
    -o ashift=12 \
    -o autotrim=on \
    -O compression=zstd \
    -O acltype=posixacl \
    -O atime=off \
    -O xattr=sa \
    -O normalization=formD \
    -O mountpoint=none \
    -R /mnt \
    "${encryption_options[@]}" \
    zroot "$ZFSDISK"

log "INFO" "Creating /"
zfs create -o mountpoint=none zroot/root
zfs create -o mountpoint=legacy zroot/root/nixos
zfs snapshot zroot/root/nixos@blank
mount -t zfs zroot/root/nixos /mnt

log "INFO" "Mounting /boot (efi)"
mount --mkdir "$BOOTDISK" /mnt/boot

log "INFO" "Creating /nix"
zfs create -o mountpoint=legacy zroot/root/nix
mount --mkdir -t zfs zroot/root/nix /mnt/nix

log "INFO" "Creating /tmp"
zfs create -o mountpoint=legacy zroot/root/tmp
mount --mkdir -t zfs zroot/root/tmp /mnt/tmp

log "INFO" "Creating /cache"
zfs create -o mountpoint=legacy zroot/root/cache
mount --mkdir -t zfs zroot/root/cache /mnt/cache

log "INFO" "Creating /home"
zfs create -o mountpoint=legacy zroot/home
mount --mkdir -t zfs zroot/home /mnt/home

restore_snapshot=$(yesno "Do you want to restore from a persist snapshot?")
if [[ $restore_snapshot == "y" ]]; then
    read -p "Enter full path to snapshot: " snapshot_file_path
    log "INFO" "Creating /persist"
    zfs receive -o mountpoint=legacy zroot/persist < "$snapshot_file_path"
else
    log "INFO" "Creating /persist"
    zfs create -o mountpoint=legacy zroot/persist
fi

mount --mkdir -t zfs zroot/persist /mnt/persist

mkdir -p /mnt/persist/etc/shadow


# setup users with persistent passwords
# https://reddit.com/r/NixOS/comments/o1er2p/tmpfs_as_root_but_without_hardcoding_your/h22f1b9/
# create a password with for root and $user with:
# mkpasswd -m sha-512 'PASSWORD' | sudo tee -a /persist/etc/shadow/root
# set root password
while true; do
    # Prompt for the password
    echo -n "Enter password for user root: "
    stty -echo        # Disable echoing
    read root_password
    stty echo         # Re-enable echoing
    echo              # Move to a new line

    # Prompt for the password confirmation
    echo -n "Confirm password: "
    stty -echo
    read root_password_confirm
    stty echo
    echo              # Move to a new line

    # Check if passwords match
    if [ "$root_password" = "$root_password_confirm" ]; then
        echo "$root_password" | mkpasswd -m sha-512 --stdin | tee -a /mnt/persist/etc/shadow/root > /dev/null
        unset root_password root_password_confirm
        echo "Password set successfully."
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done


# set username
read -rp "Enter your desired username: " USER

# setup users with persistent passwords
# https://reddit.com/r/NixOS/comments/o1er2p/tmpfs_as_root_but_without_hardcoding_your/h22f1b9/
# create a password with for root and $user with:
# mkpasswd -m sha-512 'PASSWORD' | sudo tee -a /persist/etc/shadow/root
# set user password
while true; do
    # Prompt for the password
    echo -n "Enter password for user $USER: "
    stty -echo        # Disable echoing
    read user_password
    stty echo         # Re-enable echoing
    echo              # Move to a new line

    # Prompt for the password confirmation
    echo -n "Confirm password: "
    stty -echo
    read user_password_confirm
    stty echo
    echo              # Move to a new line

    # Check if passwords match
    if [ "$user_password" = "$user_password_confirm" ]; then
        echo "$user_password" | mkpasswd -m sha-512 --stdin | tee -a /mnt/persist/etc/shadow/$USER > /dev/null
        unset user_password user_password_confirm
        echo "Password set successfully."
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done


while true; do
    read -rp "Which host to install? (vm / t580) " HOST
    case $HOST in
        vm|t580 ) break;;
        * ) echo "Invalid host. Please select a valid host.";;
    esac
done

log "INFO" "Installing Red-Flake with profile ${HOST} on ${DISK}..."
nix-shell -p git nixFlakes --command \
    "nixos-install --flake \"${FLAKE}/${GIT_REV:-main}#$HOST\""

log "INFO" "Unmounting /mnt"
umount -R /mnt

log "INFO" "Exporting ZFS pool zroot"
zpool export -f zroot

log "INFO" "Installation finished. It is now safe to reboot."

do_reboot=$(yesno "Do you want to reboot now?")
if [[ $do_reboot == "y" ]]; then
    reboot
fi
