# Pascal's firefox configuration
{ pkgs, ... }:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  imports = [ ../../shared/firefox-base.nix ];

  custom.firefox = {
    enable = true;
    profile = "security";
    dnsProvider = "cloudflare";
    processCount = 24;
    aggressiveAcceleration = false;
    enableScrollTuning = true;
    enableAIBlocking = true;
    bookmarks = import ./firefox-bookmarks.nix;
    extraExtensionPackages = [
      addons.betterttv
      addons.frankerfacez
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
            value = "1";
          };
        };
      };
    };
  };
}
