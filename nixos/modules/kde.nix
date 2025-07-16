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
  # KDE related packages
  environment.systemPackages = with pkgs; [
    # additional KDE packages to be installed
    kdePackages.powerdevil
    krita
    kdePackages.krdc
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.kwalletmanager
    kdePackages.ksshaskpass

    # Install custom sddm theme.conf.user
    (
      writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
        [General]
        background = ${background-package}
      ''
    )
  ];

  # make sure the plasma-powerdevil service runs
  systemd.user.services.plasma-powerdevil = {
    enable      = true;
    description = "KDE Powerdevil power-management daemon";

    # Don’t tie to graphical-session.target
    unitConfig = {
      After = "dbus.service";            # ensure D-Bus is up
    };

    serviceConfig = {
      ExecStart      = "${pkgs.kdePackages.powerdevil}/libexec/org_kde_powerdevil";
      Type           = "dbus";
      BusName        = "org.kde.Solid.PowerManagement";
      Restart        = "always";        # restart even after TERM
      RestartSec     = "5s";
      # Optional: disable DDC if that’s crashing you
      # Environment  = "POWERDEVIL_NO_DDCUTIL=1";
    };

    # Hook it into your user manager, not just the graphical session
    wantedBy = [ "default.target" ];
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

  # Desktop-Manager settings
  services.desktopManager = {
    # Enable Plasma 6
    plasma6.enable = true;
  };

  # Enable XWayland
  programs.xwayland.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

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

  # set /etc/xdg/menus/applications-merged
  environment.etc."xdg/menus/applications-merged/redflake-applications.menu".source = ./xdg/redflake-applications.menu;

  # Env Variables
  environment.sessionVariables = {

    # Electron and Chromium
    ## As of NixOS 22.05 ("Quokka"), you can enable Ozone Wayland support in Chromium and Electron based applications by setting the environment variable NIXOS_OZONE_WL=1. For example, in a configuration.nix: 
    NIXOS_OZONE_WL = "1";

    # this env is useful for electron wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # variable for qt (wayland with fallback to x11)
    QT_QPA_PLATFORM = "wayland;xcb";

    # set sessiontype
    XDG_SESSION_TYPE = "wayland";

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

  # KDE PAM Settings
  security.pam.services = {
    login.kwallet = {
      enable = true;
    };
    sddm.kwallet = {
      enable = true;
    };
    kde.kwallet = {
      enable = true;
    };
    kde-fingerprint = lib.mkIf config.services.fprintd.enable { fprintAuth = true; };
    kde-smartcard = lib.mkIf config.security.pam.p11.enable { p11Auth = true; };
  };
  
}
