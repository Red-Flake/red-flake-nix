{ config, lib, pkgs, modulesPath, inputs, ... }:

let
  background-package = pkgs.stdenvNoCC.mkDerivation {
    name = "background-image";
    src = "${inputs.artwork}/wallpapers";
    dontUnpack = true;
    installPhase = ''
      cp $src/Red-Flake-Wallpaper_1920x1080.png $out
    '';
  };
  browser = "firefox.desktop";
in
{
  # X11 / Wayland settings
  services.xserver = {
     enable = true;
     videoDrivers = [ "intel amdgpu nvidia" ];
  };
   
  # Display-Manager settings
  services.displayManager = {
    # Enable SDDM
    sddm.enable = true;

    # Set default session to KDE Plasma
    defaultSession = "plasma";

    # Run SDDM under Wayland
    sddm.wayland.enable = true;

    # Set SDDM theme to breeze
    sddm.theme = "breeze";
  };

  # Install custom sddm theme.conf.user
  environment.systemPackages = [
    (
      pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background = ${background-package}
      ''
    )
  ];

  # Desktop-Manager settings
  services.desktopManager = {
    # Enable Plasma 6
    plasma6.enable = true;
  };

  # Add ~/.config/kdedefaults to XDG_CONFIG_DIRS for shells, since Plasma sets that.
  # FIXME: maybe we should append to XDG_CONFIG_DIRS in /etc/set-environment instead?
  environment.sessionVariables.XDG_CONFIG_DIRS = ["$HOME/.config/kdedefaults"];

  # Needed for things that depend on other store.kde.org packages to install correctly,
  # notably Plasma look-and-feel packages (a.k.a. Global Themes)
  #
  # FIXME: this is annoyingly impure and should really be fixed at source level somehow,
  # but kpackage is a library so we can't just wrap the one thing invoking it and be done.
  # This also means things won't work for people not on Plasma, but at least this way it
  # works for SOME people.
  environment.sessionVariables.KPACKAGE_DEP_RESOLVERS_PATH = "${pkgs.kdePackages.frameworkintegration.out}/libexec/kf6/kpackagehandlers";

  # Enable GTK applications to load SVG icons
  programs.gdk-pixbuf.modulePackages = [pkgs.librsvg];

  # Enable helpful DBus services.
  services.accounts-daemon.enable = true;
  # when changing an account picture the accounts-daemon reads a temporary file containing the image which systemsettings5 may place under /tmp
  systemd.services.accounts-daemon.serviceConfig.PrivateTmp = false;

  # Sound settings
  # Disable actkbd so KDE can handle media keys
  sound.mediaKeys.enable = false;
  
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

  # set /etc/xdg/menus/applications-merged
  environment.etc."xdg/menus/applications-merged/redflake-applications.menu".source = ./xdg/redflake-applications.menu;

  # Env Variables
  environment.sessionVariables = {

    # Electron and Chromium
    ## As of NixOS 22.05 ("Quokka"), you can enable Ozone Wayland support in Chromium and Electron based applications by setting the environment variable NIXOS_OZONE_WL=1. For example, in a configuration.nix: 
    NIXOS_OZONE_WL = "1";

    # Firefox
    ## Enable wayland for firefox
    MOZ_ENABLE_WAYLAND = "1";

    # Set X11 cursor size to 24
    XCURSOR_SIZE = "24";

    # Try to fix cursor size inconsistency
    WLR_NO_HARDWARE_CURSORS = "1";

    # Set GTK Theme to Breeze
    GTK_THEME = "Breeze";

    # Set default browser to firefox
    DEFAULT_BROWSER = "${pkgs.firefox-bin}/bin/firefox";
  };
  
}
