# Pascal's firefox configuration
{ pkgs, osConfig, ... }:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  imports = [ ../../shared/firefox-base.nix ];

  custom.firefox = {
    enable = true;
    profile = "security";
    searchEngine = "startpage";
    dnsProvider = "none";
    defaultZoom = 110;
    processCount = 24;
    aggressiveAcceleration = false;
    enableScrollTuning = true;
    enableAIBlocking = true;
    bookmarks = import ./firefox-bookmarks.nix;
    extraExtensionPackages = [
      addons.betterttv
      addons.frankerfacez
      # Reports the active tab's URL to ActivityWatch (see modules/productivity)
      addons.aw-watcher-web
    ];
    extraExtensionSettings = {
      "${addons.bitwarden.addonId}" = {
        force = true;
        settings = {
          global_loginEmail_storedEmail = "ppeinecke@netcat.rocks";
          global_vaultBrowserIntroCarousel_introCarouselDismissed = true;
          global_extensionInitialInstall_extensionInstalled = true;
          global_vaultAppearance_copyButtons = "quick";
          global_vaultSettings_enablePasskeys = false;
          global_autofillSettingsLocal_inlineMenuVisibility = {
            __json__ = true;
            value = "2";
          };
        };
      };
      # aw-watcher-web only enables itself and detects the hostname in its
      # onInstalled handler, which never fires for extensions placed in the
      # profile by Home Manager. Seed what that handler would store.
      "${addons.aw-watcher-web.addonId}".settings = {
        enabled = true;
        consentRequired = false;
        consent = true;
        hostname = osConfig.networking.hostName;
      };
    };
  };

  # Consent for aw-watcher-web given by policy, so a reinstall does not open the
  # consent tab. The data only goes to the local ActivityWatch server (127.0.0.1:5600).
  programs.firefox.policies."3rdparty".Extensions.${addons.aw-watcher-web.addonId}.consentOfflineDataCollection = true;
}
