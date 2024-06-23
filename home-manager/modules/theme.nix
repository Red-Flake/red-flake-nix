{ config, lib, pkgs, inputs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "Flat-Remix-Blue-Dark";
      package = pkgs.flat-remix-icon-theme;
    };
    cursorTheme = {
      name = "Breeze";
      package = pkgs.kdePackages.breeze;
      size = 32;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

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
