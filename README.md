[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-informational?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)
&ensp;
[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&style=flat-square&logoColor=fff)](#)
&ensp;
[![Home-Manager Master](https://img.shields.io/badge/home_manager-master-blue?style=flat-square)](#)
&ensp;
[![KDE Plasma 6](https://img.shields.io/badge/KDE_Plasma-6-blue?style=flat-square)](#)

<br><br>

<h1 align="center">
   <img src="https://raw.githubusercontent.com/Red-Flake/artwork/main/logos/RedFlake_Logo_256x256px.png" width="160"/> 
   <br>
   Red-Flake Nix Flake
</h1>

<br><br><br>

# Installation

<br>

1. Bootup any NixOS live CD
2. Install Red Flake (run as root, do not use sudo):

```bash
bash <(curl -L https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/install.sh)
```

<br><br>

# Rebuilding

<br>

Rebuild the already installed system from the flake

```bash
bash <(curl -L https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/rebuild.sh)
```

<br><br>

# Features

<br>

- custom NixOS flake using NixOS unstable
- NixOS home-manager
- encrypted root on ZFS
- Impermanence (non-persistent root on tmpfs) with persistence on /persist
- GRUB bootloader with EFI support & theme
- performance tweaks
- custom Red-Flake themes
- custom Red-Flake boot logo
- custom Red-Flake wallpaper
- customized KDE desktop
- customized KDE start menu
- pre-configured, ready-to-use tools for penetration testing, red teaming & CTFs
- additional standalone tools in `/usr/share/tools`
- various wordlists in `/usr/share/wordlists`
- various webshells in `/usr/share/webshells`
- customized zsh shell with oh-my-zsh
- support for Docker, LXC, KVM & VirtualBox
- postgres & neo4j databases for metasploit & bloodhound
- provide automatic provisioning for
   - Zsh
   - KDE Plasma
   - metasploit framework
   - postgresql
   - BloodHound
   - Neo4j
   - Burp Suite
   - Firefox
   - ... and more

<br><br>

# Showcase

<br>

## fastfetch

![](assets/screenshots/fastfetch.png)

## KDE about this system

![](assets/screenshots/kde_about_this_system.png)

## KDE desktop

![](assets/screenshots/kde_desktop_tidy.png)

<br>

## KDE start menu

![](assets/screenshots/kde_start_menu.png)

<br><br>

# Contributing

Community contributions are always welcome through GitHub Issues and
Pull Requests.

<br><br>

# License

Red-Flake is licensed under the [GPL License](LICENSE).
