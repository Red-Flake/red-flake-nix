{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;

    profiles.redflake = {
      id = 0;
      name = "Red-Flake";
      isDefault = true;

      search = {
        default = "duckduckgo";
        force = true;
      };

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "toolkit.telemetry.enabled" = false;
        "browser.startup.page" = 1;
        "browser.newtabpage.enabled" = true;
        "browser.newtabpage.activity-stream.topSitesRows" = 2;
        "browser.newtabpage.storageVersion" = 1;
        "browser.newtabpage.pinned" = [
          {
            label = "GitHub";
            url = "https://github.com";
          }
          {
            label = "YouTube";
            url = "https://youtube.com";
          }
          {
            label = "YT Music";
            url = "https://music.youtube.com";
          }
          {
            label = "Monkeytype";
            url = "https://monkeytype.com";
          }
        ];

        "browser.newtab.preload" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.sections" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";

        "browser.in-content.dark-mode" = true;
        "ui.systemUsesDarkTheme" = 1;
        # disable alt key bringing up window menu
        "ui.key.menuAccessKeyFocuses" = false;

        "browser.theme.toolbar-theme" = 0;
        "browser.theme.content-theme" = 0;

        "media.eme.enabled" = true;
        "media.gmp-widevinecdm.visible" = true;
        "media.gmp-widevinecdm.enabled" = true;

        "browser.discovery.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pocket.enabled" = false;

        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;

        "cookiebanners.service.mode" = 2;
        "cookiebanners.service.mode.privateBrowsing" = 2;

        "media.autoplay.default" = 5;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "dom.security.https_only_mode" = false;
        "network.trr.mode" = 2;
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
        "network.dns.echconfig.enabled" = true;
        "network.dns.http3_echconfig.enabled" = true;
        "browser.contentblocking.category" = "strict";
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.resistFingerprinting.pbmode" = true;
        "privacy.firstparty.isolate" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "media.peerconnection.ice.default_address_only" = true;
        "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "widget.dmabuf.force-enabled" = true;
      };

      extraConfig = ''
        user_pref("browser.theme.content-theme", 0);
        user_pref("browser.theme.toolbar-theme", 0);
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
        user_pref("full-screen-api.ignore-widgets", true);
        user_pref("full-screen-api.warning.timeout", 0);
        user_pref("media.hardware-video-decoding.enabled", true);
        user_pref("media.hardware-video-decoding.force-enabled", true);
        user_pref("media.ffmpeg.vaapi.enabled", true);
        user_pref("media.rdd-vpx.enabled", true);
        user_pref("apz.overscroll.enabled", true);
        user_pref("browser.shell.checkDefaultBrowser", false);
        user_pref("privacy.resistFingerprinting", false);
        user_pref("ui.systemUsesDarkTheme", 1);
        user_pref("browser.translations.automaticallyPopup", false);

        user_pref("apz.gtk.kinetic_scroll.enabled", false);
        user_pref("general.smoothScroll.lines.durationMaxMS", 125);
        user_pref("general.smoothScroll.lines.durationMinMS", 125);
        user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 200);
        user_pref("general.smoothScroll.mouseWheel.durationMinMS", 100);
        user_pref("general.smoothScroll.msdPhysics.enabled", true);
        user_pref("general.smoothScroll.other.durationMaxMS", 125);
        user_pref("general.smoothScroll.other.durationMinMS", 125);
        user_pref("general.smoothScroll.pages.durationMaxMS", 125);
        user_pref("general.smoothScroll.pages.durationMinMS", 125);
        user_pref("mousewheel.min_line_scroll_amount", 30);
        user_pref("mousewheel.system_scroll_override_on_root_content.enabled", true);
        user_pref("mousewheel.system_scroll_override_on_root_content.horizontal.factor", 175);
        user_pref("mousewheel.system_scroll_override_on_root_content.vertical.factor", 175);
        user_pref("toolkit.scrollbox.horizontalScrollDistance", 6);
        user_pref("toolkit.scrollbox.verticalScrollDistance", 2);
      '';

    };

    policies = {
      
      ExtensionSettings = {
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "wappalyzer@crunchlabz.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "{f6ca2dfb-43a6-4334-9fad-8d5a71a1fe67}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-modify-header/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "simple-translate@sienori" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-translate/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "foxyproxy@eric.h.jung" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "{c3c10168-4186-445c-9c5b-63f12b8e2c87}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/cookie-editor/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
      };
    };

      # extraConfig = '' ''; # user.js
      # userChrome = '' ''; # chrome CSS
      # userContent = '' ''; # content CSS
  };

}
