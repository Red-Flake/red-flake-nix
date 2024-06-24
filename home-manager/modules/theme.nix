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
  #home.file.".gtkrc-2.0".force = true;

  # Enabling this seems to break the KDE settings app ...
  #qt = {
  #  enable = true;
  #  platformTheme.name = "kde";
  #  style.name = "Breeze-Dark";
  #};

  # Generic fix for gtk cursor size
  # https://www.reddit.com/r/NixOS/comments/18qpj78/comment/kf0oyjw/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  home.file.".local/share/icons/default/index.theme".text = ''
    [Icon Theme]
    Inherits=breeze_cursors
  '';

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
