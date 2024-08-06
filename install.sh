#!/bin/sh
#
# For installing NixOS having booted from the minimal USB image.
#
# To run:
#
#     bash -c "$(curl https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/install.sh)"
#

# Set the flake
FLAKE="github:Red-Flake/red-flake-nix#redflake"

# Prompt the user to choose a drive
echo "--------------------------------------------------------------------------------"
echo "Your attached storage devices will now be listed."
read -p "Press 'q' to exit the list. Press enter to continue." NULL

sudo fdisk -l | less

echo "--------------------------------------------------------------------------------"
echo "Detected the following devices:"
echo

i=0
for device in $(sudo fdisk -l | grep "^Disk /dev" | awk "{print \$2}" | sed "s/://"); do
    device_name=$(basename $device)  # Extract the device name without the /dev/ prefix
    echo "[$i] $device_name"
    i=$((i+1))
    DEVICES[$i]=$device_name
done

echo
read -p "Which device do you wish to install on? " DEVICE

# Get the full device path
DEV="/dev/${DEVICES[$(($DEVICE+1))]}"

# Extract just the device name (e.g., sda)
DEV_NAME=$(basename $DEV)

# Check if the device exists
if [ ! -b "$DEV" ]; then
    echo "Error: Device $DEV does not exist."
    exit 1
fi

read -p "Will now install Red-Flake to ${DEV}. Ok? Type 'install': " ANSWER

if [ "$ANSWER" = "install" ]; then
    echo "Creating new GPT partition table..."
    sudo sgdisk -o ${DEV}
    echo "Installing Red-Flake on ${DEV}..."
    
    # Run disko
    sudo nix \
        --experimental-features "nix-command flakes" \
        run github:nix-community/disko -- \
        --mode disko ./disko.nix

    # Run nixos-install
    sudo nixos-install \
        --root /mnt \
        --flake 'github:Red-Flake/red-flake-nix#redflake' \
        --option eval-cache false

else
    echo "cancelled."
    exit
fi

read -p "The installation was finished!\nRemove installation media and press enter to reboot." NULL

sudo reboot
