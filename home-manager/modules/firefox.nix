{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {

  # force creation of ~/.mozilla/firefox/profiles.ini otherwise home-manager will fail
  home.file.".mozilla/firefox/profiles.in".force = true;

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
        "browser.startup.page" = 3; # Open windows and tabs from the last session
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.max_resumed_crashes" = -1;
        "browser.newtabpage.enabled" = true;
        "browser.newtabpage.activity-stream.topSitesRows" = 2;
        "browser.newtabpage.storageVersion" = 1;

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

        "browser.tabs.tabmanager.enabled" = false;

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
        "extensions.getAddons.cache.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pocket.enabled" = false;
        "extensions.screenshots.disabled" = true;
        "extensions.blocklist.enabled" = false;
        "identity.fxaccounts.enabled" = false;

        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.coverage.endpoint.base" = "";
        "toolkit.coverage.opt-out" = true;
        "toolkit.telemetry.coverage.opt-out" = true;
        "browser.region.update.enabled" = false;
        "browser.region.network.url" = "";
        "browser.aboutHomeSnippets.updateUrl" = "";
        "browser.selfsupport" = false;

        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.blockedURIs.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.downloads.remote.block_dangerous" = false;
        "browser.safebrowsing.downloads.remote.block_dangerous_host" = false;
        "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
        "browser.safebrowsing.downloads.remote.block_uncommon" = false;
        "browser.safebrowsing.downloads.remote.url" = "";
        "browser.safebrowsing.provider.*.gethashURL" = "";
        "browser.safebrowsing.provider.*.updateURL" = "";
        "browser.pagethumbnails.capturing_disabled" = true;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "extensions.ui.lastCategory" = "about:addons";
        "browser.vpn_promo.enabled" = false;
        "app.normandy.enabled" = false;
        "extensions.webextensions.restrictedDomains" = "";
        "network.connectivity-service.enabled" = false;
        "browser.search.geoip.url" = "";

        "cookiebanners.service.mode" = 2;
        "cookiebanners.service.mode.privateBrowsing" = 2;

        "media.autoplay.default" = 5;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "dom.security.https_only_mode" = false;
        "dom.serviceWorkers.enabled" = false;
        "network.trr.mode" = 1;
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
        "network.dns.echconfig.enabled" = true;
        "network.dns.http3_echconfig.enabled" = true;
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "media.peerconnection.ice.default_address_only" = true;
        "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "browser.formfill.enable" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.heuristics.enabled" = false;
        "signon.formlessCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "webgl.enable-debug-renderer-info" = false;
        "network.http.speculative-parallel-limit" = 0;

        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };

      extraConfig = ''
        user_pref("browser.theme.content-theme", 0);
        user_pref("browser.theme.toolbar-theme", 0);
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
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

        user_pref("apz.gtk.kinetic_scroll.enabled", true);

        user_pref("browser.bookmarks.defaultLocation", "toolbar");
        user_pref("browser.toolbars.bookmarks.visibility", "always");

        user_pref("browser.tabs.loadBookmarksInTabs", true);
      '';

      bookmarks = [
        {
          name = "toolbar";
          toolbar = true;
          bookmarks = [
            {
              name = "Red-Flake";
              tags = [ "redflake" ];
              keyword = "redflake";
              url = "https://github.com/Red-Flake";
            }
            {
              name = "Platforms";
              bookmarks = [
                {
                  name = "HTB Main";
                  tags = [ "htb" ];
                  keyword = "htb";
                  url = "https://app.hackthebox.com";
                }
                {
                  name = "HTB Academy";
                  tags = [ "htb" ];
                  keyword = "htb";
                  url = "https://academy.hackthebox.com";
                }
                {
                  name = "HTB CTF";
                  tags = [ "htb" ];
                  keyword = "htb";
                  url = "https://ctf.hackthebox.com";
                }
                {
                  name = "TryHackMe";
                  tags = [ "thm" ];
                  keyword = "thm";
                  url = "https://tryhackme.com/";
                }
                {
                  name = "OverTheWire";
                  tags = [ "overthewire" ];
                  keyword = "overthewire";
                  url = "https://overthewire.org/wargames/";
                }
                {
                  name = "PortSwigger Academy";
                  tags = [ "portswigger" ];
                  keyword = "portswigger";
                  url = "https://portswigger.net/web-security";
                }
              ];
            }
            {
              name = "AI";
              bookmarks = [
                {
                  name = "ChatGPT";
                  tags = [ "chatgpt" ];
                  keyword = "chatgpt";
                  url = "https://chatgpt.com";
                }
              ];
            }
            {
              name = "Git";
              bookmarks = [
                {
                  name = "GitHub";
                  tags = [ "github" ];
                  keyword = "github";
                  url = "https://github.com";
                }
                {
                  name = "GitLab";
                  tags = [ "gitlab" ];
                  keyword = "gitlab";
                  url = "https://gitlab.com";
                }
                {
                  name = "Codeberg";
                  tags = [ "codeberg" ];
                  keyword = "codeberg";
                  url = "https://codeberg.org/";
                }
              ];
            }
            {
              name = "OSINT";
              bookmarks = [
                {
                  name = "WayBackMachine";
                  tags = [ "WayBackMachine" ];
                  keyword = "WayBackMachine";
                  url = "https://archive.org/";
                }
                {
                  name = "Shodan";
                  tags = [ "shodan" ];
                  keyword = "shodan";
                  url = "https://www.shodan.io/";
                }
                {
                  name = "censys";
                  tags = [ "censys" ];
                  keyword = "censys";
                  url = "https://search.censys.io/";
                }
                {
                  name = "URLHaus abuse";
                  tags = [ "abuse" ];
                  keyword = "abuse";
                  url = "https://urlhaus.abuse.ch/browse/";
                }
                {
                  name = "C2 Tracker";
                  tags = [ "tracker" ];
                  keyword = "tracker";
                  url = "https://tracker.viriback.com/";
                }
                {
                  name = "Threatcenter";
                  tags = [ "threatcenter" ];
                  keyword = "threatcenter";
                  url = "https://threatcenter.crdf.fr/";
                }
                {
                  name = "intelx";
                  tags = [ "intelx" ];
                  keyword = "intelx";
                  url = "https://intelx.io/";
                }
                {
                  name = "OSINT Framework";
                  tags = [ "osint" ];
                  keyword = "osint";
                  url = "https://osintframework.com/";
                }
                {
                  name = "IntelTechniques";
                  tags = [ "inteltechniques" ];
                  keyword = "inteltechniques";
                  url = "https://inteltechniques.com/tools/Search.html";
                }
              ];
            }
            {
              name = "BugBounty";
              bookmarks = [
                {
                  name = "HackerOne";
                  tags = [ "hackerone" ];
                  keyword = "hackerone";
                  url = "https://www.hackerone.com/";
                }
                {
                  name = "bugcrowd";
                  tags = [ "bugcrowd" ];
                  keyword = "bugcrowd";
                  url = "https://www.bugcrowd.com/";
                }
              ];
            }
            {
              name = "Auth";
              bookmarks = [
                {
                  name = "jwt.io";
                  tags = [ "jwt.io" ];
                  keyword = "jwt.io";
                  url = "https://jwt.io/";
                }
                {
                  name = "oauth.tools";
                  tags = [ "oauth.tools" ];
                  keyword = "oauth.tools";
                  url = "https://oauth.tools/";
                }
              ];
            }
            {
              name = "GTFOBins";
              bookmarks = [
                {
                  name = "GTFOBins";
                  tags = [ "gtfobins" ];
                  keyword = "gtfobins";
                  url = "https://gtfobins.github.io/";
                }
                {
                  name = "LOLBAS ";
                  tags = [ "lolbas" ];
                  keyword = "lolbas";
                  url = "https://lolbas-project.github.io/";
                }
              ];
            }
            {
              name = "Crackstation";
              tags = [ "crackstation" ];
              keyword = "crackstation";
              url = "https://crackstation.net";
            }
            {
              name = "CyberChef";
              tags = [ "cyberchef" ];
              keyword = "cyberchef";
              url = "https://gchq.github.io/CyberChef/";
            }
            {
              name = "HackTricks";
              tags = [ "hacktricks" ];
              keyword = "hacktricks";
              url = "https://book.hacktricks.xyz/";
            }
            {
              name = "Synk Code Checker";
              tags = [ "snyk" ];
              keyword = "synk";
              url = "https://snyk.io/code-checker/";
            }
            {
              name = "IP Adderss Converter";
              tags = [ "ip, converter" ];
              keyword = "converter";
              url = "https://www.abuseipdb.com/tools/ip-address-converter";
            }
          ];
        }
      ];

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
        "default-compact-dark-theme@glitchii.github.io" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/default-compact-dark-theme/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

      # extraConfig = '' ''; # user.js
      # userChrome = '' ''; # chrome CSS
      # userContent = '' ''; # content CSS
  };

}
