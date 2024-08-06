#!/bin/bash

# Function to display available drives and prompt for the user to select one
choose_drive() {
    echo "Available drives:"
    lsblk -d -o NAME,SIZE,TYPE | grep disk | while IFS= read -r line; do
        echo "$line"
    done
    echo
    read -p "Enter the device name (e.g., sda) to install to: " drive
    echo "/dev/$drive"
}

# Set the flake
FLAKE="github:Red-Flake/red-flake-nix#redflake"

# Prompt the user to choose a drive
DISK_DEVICE=$(choose_drive)

# Check if the drive exists
if [ ! -b "$DISK_DEVICE" ]; then
    echo "Error: Device $DISK_DEVICE does not exist."
    exit 1
fi

# Run the nix command with the chosen drive
sudo nix \
    --extra-experimental-features 'flakes nix-command' \
    run github:nix-community/disko#disko-install -- \
    --flake "$FLAKE" \
    --write-efi-boot-entries \
    --disk main "$DISK_DEVICE"
