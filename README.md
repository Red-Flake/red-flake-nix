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
2. Install Red Flake:

```bash
bash -c "$(curl -s https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/install.sh)"
```

<br><br>

# Rebuilding

<br>

Rebuild the already installed system from the flake

```bash
sudo nixos-rebuild switch --install-bootloader --flake 'github:Red-Flake/red-flake-nix#redflake' --option eval-cache false
```

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
