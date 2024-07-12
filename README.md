[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-informational?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)
[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=fff)](#)

# red-flake-nix

<p align="center">
<img src="https://raw.githubusercontent.com/Red-Flake/artwork/main/logos/RedFlake_Logo_256x256px.png">
</p>
<p style="text-align: center;">Red-Flake Nix flake</p>

<br>

## Install (as root)

<br>

### clone the repo

<br>

first clone the repo into /root
```bash
nix-shell -p git
```
```bash
git clone https://github.com/Red-Flake/red-flake-nix /root/red-flake-nix
```

then enter the directory
```bash
cd /root/red-flake-nix
```

<br>

### hardware-configuration

<br>

then generate your system's `hardware-configuration.nix`
```bash
nixos-generate-config --show-hardware-config > /root/red-flake-nix/nixos/hardware-configuration.nix
```

After you generated `hardware-configuration.nix` you need to track it by Git because otherwise it cannot be built using the flake.
```bash
git add --intent-to-add /root/red-flake-nix/nixos/hardware-configuration.nix
```

```bash
git update-index --assume-unchanged /root/red-flake-nix/nixos/hardware-configuration.nix
```

<br>

### installation

<br>

finally install the flake
```bash
nixos-rebuild --install-bootloader switch --flake '/root/red-flake-nix#redflake'
```
