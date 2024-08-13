{ config, lib, pkgs, ... }:
{
    # dconf user settings
    # Fix GTK themes not applied in Wayland
    dconf.settings = {
        
        "org/gnome/desktop/interface" = {
          gtk-theme = lib.mkForce "Breeze-Dark";
          icon-theme = lib.mkForce "Papirus-Dark";
          color-scheme = lib.mkForce "prefer-dark";
          cursor-theme = lib.mkForce "Bibata-Modern-Classic";
          cursor-size = lib.mkForce 24;
        };

        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };

      };
    };
}
