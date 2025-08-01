{ config, lib, pkgs, ... }:

let
  browser = "firefox.desktop";
in
{

  home.activation = {
    mimeapps = lib.hm.dag.entryBefore ["writeBoundary"] ''
      # Check if ~/.config/mimeapps.list exists
      if [ -f "${config.xdg.configHome}/mimeapps.list" ]; then
        # Ensure the existing config file is removed before activation
        rm -f "${config.xdg.configHome}/mimeapps.list"
      fi
    '';
  };

  # enable xdg desktop portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
    configPackages = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  # enable XDG mime
  xdg.mime = { enable = true; };

  # set default XDG mime applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # set default browser
      "text/html" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "application/xhtml+xml" = browser;
      "application/x-extension-xht" = browser;
      "application/x-extension-xhtml" = browser;
      "application/x-extension-shtml" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
      "x-scheme-handler/chrome" = browser;
    };
    associations = {
      added = {
        # set default browser
        "text/html" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-xht" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-shtml" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "x-scheme-handler/chrome" = browser;
      };
    };
  };
}