# Let's firefox configuration
{ pkgs, ... }:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  imports = [ ../../shared/firefox-base.nix ];

  custom.firefox = {
    enable = true;
    profile = "streaming";
    dnsProvider = "mullvad";
    processCount = 8;
    aggressiveAcceleration = true;
    enableScrollTuning = true;
    enableAIBlocking = false;
    bookmarks = import ./firefox-bookmarks.nix;
    extraExtensionSettings = {
      # Bitwarden - Letgamer's Vaultwarden instance
      "${addons.bitwarden.addonId}" = {
        force = true;
        settings = {
          global_environment_environment = {
            region = "Self-hosted";
            urls.base = "https://vaultwarden.let-net.cc";
          };
          global_loginEmail_storedEmail = "alexstephan005@protonmail.com";
          global_vaultBrowserIntroCarousel_introCarouselDismissed = true;
          global_extensionInitialInstall_extensionInstalled = true;
          global_vaultAppearance_copyButtons = "quick";
          global_vaultSettings_enablePasskeys = false;
          global_autofillSettingsLocal_inlineMenuVisibility = {
            __json__ = true;
            value = "2";
          };
          user_5450439a-482e-48fe-91ba-a0fecf259c67_autofillSettings_autofillOnPageLoad = true;
          user_5450439a-482e-48fe-91ba-a0fecf259c67_autofillSettings_autofillOnPageLoadDefault = true;
          user_5450439a-482e-48fe-91ba-a0fecf259c67_domainSettings_defaultUriMatchStrategy = 1;
        };
      };
    };
  };
}
