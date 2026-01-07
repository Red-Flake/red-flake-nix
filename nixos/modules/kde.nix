{ config
, lib
, pkgs
, inputs
, ...
}:

let
  resolution = lib.attrByPath [ "custom" "display" "resolution" ] "1080p" config;

  # Map resolution settings to wallpaper filenames
  wallpaperFile = lib.attrByPath [ resolution ] "Red-Flake-Wallpaper_1920x1080.png" {
    "1080p" = "Red-Flake-Wallpaper_1920x1080.png";
    "1440p" = "Red-Flake-Wallpaper_2560x1440.png";
    "1600p" = "Red-Flake-Wallpaper_2560x1600.png";
    "2160p" = "Red-Flake-Wallpaper_3840x2160.png";
  };

  background-package = pkgs.stdenvNoCC.mkDerivation {
    name = "background-image";
    src = "${inputs.artwork}/wallpapers";
    dontUnpack = true;
    installPhase = ''
      install -Dm644 "$src/${wallpaperFile}" "$out/${wallpaperFile}"
    '';
  };

  backgroundPath = "${background-package}/${wallpaperFile}";
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
    (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background = ${backgroundPath}
    '')
  ];

  # make sure the plasma-powerdevil service runs
  systemd.user.services.plasma-powerdevil = {
    enable = true;
    description = "KDE Powerdevil power-management daemon";

    unitConfig = {
      # Match upstream: start after plasma-core, stop with graphical session
      After = [ "plasma-core.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.powerdevil}/libexec/org_kde_powerdevil";
      Type = "dbus";
      BusName = "org.kde.Solid.PowerManagement";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    wantedBy = [ "plasma-core.target" ];
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

  # Enable GTK applications to load SVG icons
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # Enable helpful DBus services.
  services.accounts-daemon.enable = true;
  # when changing an account picture the accounts-daemon reads a temporary file containing the image which systemsettings5 may place under /tmp
  systemd.services.accounts-daemon.serviceConfig.PrivateTmp = false;

  # set /etc/xdg/menus/applications-merged
  environment.etc."xdg/menus/applications-merged/redflake-applications.menu".source =
    ./xdg/redflake-applications.menu;

  # Env Variables
  environment.sessionVariables = {
    # Append the default config dir so Plasma's kdedefaults doesn't replace it.
    # FIXME: maybe we should append to XDG_CONFIG_DIRS in /etc/set-environment instead?
    XDG_CONFIG_DIRS = lib.mkAfter [ "/etc/xdg" ];

    # Needed for things that depend on other store.kde.org packages to install correctly,
    # notably Plasma look-and-feel packages (a.k.a. Global Themes)
    #
    # FIXME: this is annoyingly impure and should really be fixed at source level somehow,
    # but kpackage is a library so we can't just wrap the one thing invoking it and be done.
    # This also means things won't work for people not on Plasma, but at least this way it
    # works for SOME people.
    KPACKAGE_DEP_RESOLVERS_PATH = "${pkgs.kdePackages.frameworkintegration.out}/libexec/kf6/kpackagehandlers";

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
    DEFAULT_BROWSER = lib.getExe pkgs.firefox-bin;

    # Performance: Enable Triple Buffering for KWin (smoother, slightly higher latency)
    KWIN_TRIPLE_BUFFER = "1";

    # Performance: Disable server-side decorations for Qt apps (KWin handles it faster)
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Performance: Ensure efficient buffer sharing with modifiers
    KWIN_DRM_USE_MODIFIERS = "1";
  };

  # Disable Baloo content indexing to prevent micro-stutters
  environment.etc."xdg/baloofilerc".text = ''
    [Basic Settings]
    Indexing-Enabled=false
    
    [General]
    dbVersion=2
    exclude filters=*.iso,*.mkv,*.mp4,*.avi,*.pyc,*.class,*.o,*.obj,*.tmp,*.bak,*.swp,node_modules,target,build,dist,.git,.svn
    exclude filters version=2
    first run=false
    only basic indexing=true
  '';

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
