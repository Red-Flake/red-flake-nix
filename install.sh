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
    echo "[$i] $device"
    i=$((i+1))
    DEVICES[$i]=$device
done

echo
read -p "Which device do you wish to install on? " DEVICE

DEV=${DEVICES[$(($DEVICE+1))]}

# Check if the device exists
if [ ! -b "$DEV" ]; then
    echo "Error: Device /dev/$DEV does not exist."
    exit 1
fi

read -p "Will now install Red-Flake to /dev/${DEV}. Ok? Type 'install': " ANSWER

if [ "$ANSWER" = "install" ]; then
    echo "Creating new GPT partition table..."
    sudo sgdisk -o /dev/${DEV}
    echo "Installing Red-Flake on /dev/${DEV}..."
    # Run the nix command with the chosen drive
    sudo nix \
        --extra-experimental-features 'flakes nix-command' \
        run github:nix-community/disko#disko-install -- \
        --flake "${FLAKE}" \
        --write-efi-boot-entries \
        --disk main "${DEV}" \
        --argstr rootDisk "${DEV}"
else
    echo "cancelled."
    exit
fi

read -p "The installation was finished!\nRemove installation media and press enter to reboot." NULL

reboot
