# Common firefox configuration
# Imports the shared base with default security settings
{ ... }:
{
  imports = [ ../../shared/firefox-base.nix ];

  custom.firefox = {
    enable = true;
    profile = "security";
    searchEngine = "startpage";
    dnsProvider = "cloudflare";
    defaultZoom = 100;
    processCount = 8;
    aggressiveAcceleration = false;
    enableScrollTuning = true;
    enableAIBlocking = true;
    bookmarks = import ./firefox-bookmarks.nix;
  };
}
