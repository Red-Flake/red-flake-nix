#!/usr/bin/env bash

# For installing NixOS having booted from the minimal USB image.
# To run:
#     bash -c "$(curl https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/install.sh)"

# e: Exit script immediately if any command returns a non-zero exit status.
# u: Exit script immediately if an undefined variable is used.
# o pipefail: Ensure Bash pipelines return a non-zero status if any command fails.
set -eou pipefail

LOGFILE="/tmp/nixos_install.log"

function log() {
    local level="$1"
    local message="$2"
    echo "[$level] $message" | tee -a "$LOGFILE"
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
for cmd in sudo blkdiscard sgdisk zpool zfs mkfs.fat mkswap swapon; do
    check_command "$cmd"
done

# Network connectivity check
if ! ping -c 1 github.com &> /dev/null; then
    log "ERROR" "Network connectivity check failed. Please ensure you have an active internet connection."
    exit 1
fi

# Check if in a VM
if [[ -b "/dev/vda" ]]; then
    DISK="/dev/vda"
    BOOTDISK="${DISK}3"
    SWAPDISK="${DISK}2"
    ZFSDISK="${DISK}1"
else
    log "INFO" "Your attached storage devices will now be listed."
    read -p "Press enter to continue." NULL

    log "INFO" "Detected the following devices:"
    ls -al /dev/disk/by-id

    read -p "Which device do you wish to install on? " DISKINPUT
    DISK="/dev/disk/by-id/${DISKINPUT}"

    if [ ! -b "$DISK" ]; then
        log "ERROR" "Device $DISK does not exist."
        exit 1
    fi

    BOOTDISK="${DISK}-part3"
    SWAPDISK="${DISK}-part2"
    ZFSDISK="${DISK}-part1"

    log "INFO" "Boot Partition: $BOOTDISK"
    log "INFO" "SWAP Partition: $SWAPDISK"
    log "INFO" "ZFS Partition: $ZFSDISK"

    do_format=$(yesno "Will now install Red-Flake to ${DISK}. This irreversibly formats the entire disk. Are you sure?")
    if [[ $do_format == "n" ]]; then
        exit
    fi
fi

log "INFO" "Erasing disk..."
if ! sudo blkdiscard -f "$DISK"; then
    log "ERROR" "Failed to erase disk $DISK."
    exit 1
fi

log "INFO" "Creating new GPT partitions table..."
if ! sudo sgdisk -o "$DISK"; then
    log "ERROR" "Failed to create GPT partitions table on $DISK."
    exit 1
fi

log "INFO" "Creating partitions..."
if ! sudo sgdisk -n3:1M:+1G -t3:EF00 "$DISK"; then
    log "ERROR" "Failed to create boot partition on $DISK."
    exit 1
fi

if ! sudo sgdisk -n2:0:+16G -t2:8200 "$DISK"; then
    log "ERROR" "Failed to create swap partition on $DISK."
    exit 1
fi

if ! sudo sgdisk -n1:0:0 -t1:BF01 "$DISK"; then
    log "ERROR" "Failed to create ZFS partition on $DISK."
    exit 1
fi

log "INFO" "Notifying kernel of partition changes..."
if ! sudo sgdisk -p "$DISK" > /dev/null; then
    log "ERROR" "Failed to notify kernel of partition changes on $DISK."
    exit 1
fi
sleep 5

log "INFO" "Creating Swap"
if ! sudo mkswap "$SWAPDISK" --label "SWAP"; then
    log "ERROR" "Failed to create swap on $SWAPDISK."
    exit 1
fi

if ! sudo swapon "$SWAPDISK"; then
    log "ERROR" "Failed to enable swap on $SWAPDISK."
    exit 1
fi

log "INFO" "Creating Boot Disk"
if ! sudo mkfs.fat -F 32 "$BOOTDISK" -n NIXBOOT; then
    log "ERROR" "Failed to create boot filesystem on $BOOTDISK."
    exit 1
fi

use_encryption=$(yesno "Use encryption? (Encryption must also be enabled within host config.)")
if [[ $use_encryption == "y" ]]; then
    encryption_options=(-O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt)
else
    encryption_options=()
fi

log "INFO" "Creating base zpool"
if ! sudo zpool create -f \
    -o ashift=12 \
    -o autotrim=on \
    -O compression=zstd \
    -O acltype=posixacl \
    -O atime=off \
    -O xattr=sa \
    -O normalization=formD \
    -O mountpoint=none \
    "${encryption_options[@]}" \
    zroot "$ZFSDISK"; then
    log "ERROR" "Failed to create zpool on $ZFSDISK."
    exit 1
fi

log "INFO" "Creating /"
if ! sudo zfs create -o mountpoint=legacy zroot/root; then
    log "ERROR" "Failed to create ZFS dataset for root."
    exit 1
fi

if ! sudo zfs snapshot zroot/root@blank; then
    log "ERROR" "Failed to create snapshot for root."
    exit 1
fi

if ! sudo mount -t zfs zroot/root /mnt; then
    log "ERROR" "Failed to mount root filesystem."
    exit 1
fi

log "INFO" "Mounting /boot (efi)"
if ! sudo mount --mkdir "$BOOTDISK" /mnt/boot; then
    log "ERROR" "Failed to mount boot partition."
    exit 1
fi

log "INFO" "Creating /nix"
if ! sudo zfs create -o mountpoint=legacy zroot/nix; then
    log "ERROR" "Failed to create ZFS dataset for nix."
    exit 1
fi

if ! sudo mount --mkdir -t zfs zroot/nix /mnt/nix; then
    log "ERROR" "Failed to mount nix filesystem."
    exit 1
fi

log "INFO" "Creating /tmp"
if ! sudo zfs create -o mountpoint=legacy zroot/tmp; then
    log "ERROR" "Failed to create ZFS dataset for tmp."
    exit 1
fi

if ! sudo mount --mkdir -t zfs zroot/tmp /mnt/tmp; then
    log "ERROR" "Failed to mount tmp filesystem."
    exit 1
fi

log "INFO" "Creating /cache"
if ! sudo zfs create -o mountpoint=legacy zroot/cache; then
    log "ERROR" "Failed to create ZFS dataset for cache."
    exit 1
fi

if ! sudo mount --mkdir -t zfs zroot/cache /mnt/cache; then
    log "ERROR" "Failed to mount cache filesystem."
    exit 1
fi

restore_snapshot=$(yesno "Do you want to restore from a persist snapshot?")
if [[ $restore_snapshot == "y" ]]; then
    read -p "Enter full path to snapshot: " snapshot_file_path
    log "INFO" "Creating /persist"
    if ! sudo zfs receive -o mountpoint=legacy zroot/persist < "$snapshot_file_path"; then
        log "ERROR" "Failed to restore snapshot from $snapshot_file_path."
        exit 1
    fi
else
    log "INFO" "Creating /persist"
    if ! sudo zfs create -o mountpoint=legacy zroot/persist; then
        log "ERROR" "Failed to create ZFS dataset for persist."
        exit 1
    fi
fi

if ! sudo mount --mkdir -t zfs zroot/persist /mnt/persist; then
    log "ERROR" "Failed to mount persist filesystem."
    exit 1
fi

while true; do
    read -rp "Which host to install? (redflake) " host
    case $host in
        redflake ) break;;
        * ) log "INFO" "Invalid host. Please select a valid host.";;
    esac
done

log "INFO" "Installing Red-Flake on ${DISK}..."
if ! nix-shell -p git nixFlakes --command \
    "sudo nixos-install --no-root-password --flake \"${FLAKE}\""; then
    log "ERROR" "NixOS installation failed."
    exit 1
fi

log "INFO" "Installation finished. It is now safe to reboot."

do_reboot=$(yesno "Do you want to reboot now?")
if [[ $do_reboot == "y" ]]; then
    sudo reboot
fi
