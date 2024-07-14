[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-informational?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)
[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&style=flat-square&logoColor=fff)](#)
[![Home-Manager Master](https://img.shields.io/badge/home_manager-master-blue?style=flat-square)](#)
[![KDE Plasma 6](https://img.shields.io/badge/KDE_Plasma-6-blue?style=flat-square)](#)


<h1 align="center">
   <img src="https://raw.githubusercontent.com/Red-Flake/artwork/main/logos/RedFlake_Logo_256x256px.png" width="160"/> 
   <br>
   Red-Flake Nix Flake
</h1>

<br><br>

## Install (as root)

### Clone the Repo

First, clone the repo into `/root`:

```bash
nix-shell -p git
git clone https://github.com/Red-Flake/red-flake-nix /root/red-flake-nix
cd /root/red-flake-nix
```

<br>

### Hardware Configuration

Generate your system's `hardware-configuration.nix`:

```bash
nixos-generate-config --show-hardware-config > /root/red-flake-nix/nixos/hardware-configuration.nix
```

Track the generated file with Git:

```bash
git add --intent-to-add /root/red-flake-nix/nixos/hardware-configuration.nix
git update-index --assume-unchanged /root/red-flake-nix/nixos/hardware-configuration.nix
```

<br>

### Installation

Finally, install the flake:

```bash
nixos-rebuild --install-bootloader switch --flake '/root/red-flake-nix#redflake'
```

<br>

## Showcase

### fastfetch

![](assets/screenshots/fastfetch.png)

### KDE about this system

![](assets/screenshots/kde_about_this_system.png)

### KDE desktop

![](assets/screenshots/kde_desktop_tidy.png)

### KDE start menu

![](assets/screenshots/kde_start_menu.png)