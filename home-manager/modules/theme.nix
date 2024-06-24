{ config, lib, pkgs, inputs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Breeze";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "Flat-Remix-Blue-Dark";
      package = pkgs.flat-remix-icon-theme;
    };
    cursorTheme = {
      name = "Breeze";
      package = pkgs.kdePackages.breeze;
      size = 24;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  # force creation of .gtkrc-2.0 otherwise home-manager will fail
  home.file.".gtkrc-2.0".force = true;

  # Enabling this seems to break the KDE settings app ...
  #qt = {
  #  enable = true;
  #  platformTheme.name = "kde";
  #  style.name = "Breeze-Dark";
  #};

  # Fix GTK themes not applied in Wayland
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

}
