{ pkgs
, ...
}:

{
  # enable dconf
  # Fix GTK themes not applied in Wayland
  programs.dconf.enable = true;

  # enable XDG Desktop Menu specification
  xdg.menus.enable = true;

  # enable XDG autostart
  xdg.autostart.enable = true;

  # enable XDG icons
  xdg.icons.enable = true;

  # enable XDG sounds
  xdg.sounds.enable = true;

  # enable XDG terminal exec
  xdg.terminal-exec.enable = true;

  # XDG portal settings
  xdg.portal = {
    enable = true;
    # Prefer KDE portal (matches Plasma on these hosts); gtk fallback keeps
    # flatpak/other apps working if KDE portal is unavailable.
    config.common.default = "*";
    configPackages = [
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # if you use the NixOS module and have useUserPackages = true, make sure to add:
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
