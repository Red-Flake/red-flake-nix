{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      "AppAutoUpdate" = false;
      "BackgroundAppUpdate" = false;
      "DisableFeedbackCommands" = true;
      "DisableFirefoxAccounts" = true;
      "DisableFirefoxStudies" = true;
      "DisablePocket" = true;
      "DisableTelemetry" = true;
      "DisplayBookmarksToolbar" = "always";
      "DisplayMenuBar" = "default-off";
      "DontCheckDefaultBrowser" = true;
      "EnableTrackingProtection" = {
        "Value" = true;
        "Locked" = true;
        "Cryptomining" = true;
        "Fingerprinting" = true;
        "EmailTracking" = true;
      };
      "Extensions" = {
        "Install" = [
          "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/simple-modify-header/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/simple-translate/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-basic/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi"
          "https://addons.mozilla.org/firefox/downloads/latest/shodan-addon/latest.xpi"
        ];
      };
      "ExtensionSettings" = {
        "*" = {
          "installation_mode" = "force_installed";
          "allowed_types" = ["extension"];
          "default_area" = "navbar";
        };
      };
      "ExtensionUpdate" = true;
      "FirefoxHome" = {
        "Search" = false;
        "TopSites" = false;
        "SponsoredTopSites" = false;
        "Highlights" = false;
        "Pocket" = false;
        "SponsoredPocket" = false;
        "Snippets" = false;
        "Locked" = true;
      };
      "FirefoxSuggest" = {
        "WebSuggestions" = true;
        "SponsoredSuggestions" = false;
        "ImproveSuggest" = false;
        "Locked" = true;
      };
      "GoToIntranetSiteForSingleWordEntryInAddressBar" = true;
      "HardwareAcceleration" = true;
      "NetworkPrediction" = false;
      "NewTabPage" = false;
      "NoDefaultBookmarks" = true;
      "OfferToSaveLogins" = false;
      "OfferToSaveLoginsDefault" = false;
      "PasswordManagerEnabled" = false;
      "PromptForDownloadLocation" = true;
      "RequestedLocales" = "en-US";
      "SanitizeOnShutdown" = {
        "Cache" = true;
        "Cookies" = true;
        "Downloads" = false;
        "FormData" = true;
        "History" = false;
        "Sessions" = true;
        "SiteSettings" = false;
        "OfflineApps" = true;
        "Locked" = true;
      };
      "SearchSuggestEnabled" = true;
      "ShowHomeButton" = false;
      "SSLVersionMin" = "tls1";
      "UserMessaging" = {
        "WhatsNew" = false;
        "ExtensionRecommendations" = false;
        "FeatureRecommendations" = false;
        "UrlbarInterventions" = false;
        "SkipOnboarding" = true;
        "MoreFromMozilla" = false;
        "Locked" = true;
      };
      "UseSystemPrintDialog" = true;
      "Certificates" = {
        "Install" = ["/etc/ssl/certs/BurpSuiteCA.der"];
      };
      "3rdparty" = {
        "Extensions" = {
          "foxyproxy@eric.h.jung" = {
            "mode" = "disable";
            "sync" = false;
            "autoBackup" = false;
            "showPatternProxy" = false;
            "passthrough" = "";
            "container" = {
              "incognito" = "";
              "container-1" = "";
              "container-2" = "";
              "container-3" = "";
              "container-4" = "";
            };
            "commands" = {
              "setProxy" = "";
              "setTabProxy" = "";
              "quickAdd" = "";
            };
            "data" = [
              {
                "active" = true;
                "title" = "BurpSuite";
                "type" = "http";
                "hostname" = "localhost";
                "port" = "8080";
                "username" = "";
                "password" = "";
                "cc" = "";
                "city" = "";
                "color" = "#e66100";
                "pac" = "";
                "pacString" = "";
                "proxyDNS" = true;
                "include" = [];
                "exclude" = [];
              }
            ];
          };
        };
      };
    };
  };
}
