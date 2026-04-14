# Parameterized firefox base module
{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.custom.firefox;

  addons = pkgs.nur.repos.rycee.firefox-addons;

  # Sanitize addon IDs for use in uiCustomization.state
  sanitize = s:
    lib.toLower (
      builtins.replaceStrings [ "@" "." "{" "}" ] [ "_" "_" "_" "_" ] s
    );

  # DNS provider URIs
  dnsProviderUri = {
    cloudflare = "https://mozilla.cloudflare-dns.com/dns-query";
    mullvad = "https://doh.mullvad.net/dns-query";
    none = "";
  };

  # Base settings shared across all profiles
  baseSettings = {
    # Disable remote prefs
    "remote.prefs.recommended" = false;

    # Performance settings
    "browser.preferences.defaultPerformanceSettings.enabled" = false;
    "gfx.use_text_smoothing_setting" = true;

    # Wayland / fractional scaling
    "widget.wayland.fractional-scale.enabled" = true;

    # Process count
    "dom.ipc.processCount" = cfg.processCount;

    # About config
    "browser.aboutConfig.showWarning" = false;

    # Custom CSS support
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Fullscreen warning
    "full-screen-api.warning.timeout" = 0;

    # Default browser
    "browser.shell.checkDefaultBrowser" = false;

    # Fingerprinting (disabled for pentesting)
    "privacy.resistFingerprinting" = false;

    # Translations
    "browser.translations.automaticallyPopup" = false;

    # Bookmarks
    "browser.bookmarks.defaultLocation" = "toolbar";
    "browser.toolbars.bookmarks.visibility" = "always";
    "browser.tabs.loadBookmarksInTabs" = true;
    "browser.bookmarks.restore_default_bookmarks" = false;
    "browser.bookmarks.addedImportButton" = true;

    # Disable search suggestions in order to suggest bookmarks, history and open tabs instead
    "browser.search.suggest.enabled" = false;

    # Session restore
    "browser.startup.page" = 3;
    "browser.sessionstore.resume_from_crash" = true;
    "browser.sessionstore.max_resumed_crashes" = 2;
    "browser.sessionstore.restore_on_demand" = true;
    "browser.sessionstore.restore_pinned_tabs_on_demand" = true;
    "browser.startup.couldRestoreSession.count" = -1;

    # New tab page
    "browser.newtabpage.enabled" = true;
    "browser.newtabpage.activity-stream.topSitesRows" = 2;
    "browser.newtabpage.storageVersion" = 1;
    "browser.newtab.preload" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.system.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.feeds.sections" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
    "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";

    # Sidebar
    "sidebar.revamp" = false;

    # Tab manager
    "browser.tabs.tabmanager.enabled" = false;

    # Dark mode
    "browser.in-content.dark-mode" = true;
    "ui.systemUsesDarkTheme" = 1;
    "ui.key.menuAccessKeyFocuses" = false;
    "browser.theme.toolbar-theme" = 0;
    "browser.theme.content-theme" = 0;
    "layout.css.prefers-color-scheme.content-override" = 0;

    # DRM/Media
    "media.eme.enabled" = true;
    "media.gmp-widevinecdm.visible" = true;
    "media.gmp-widevinecdm.enabled" = true;

    # Extensions
    "browser.discovery.enabled" = false;
    "extensions.getAddons.showPane" = false;
    "extensions.getAddons.cache.enabled" = false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;
    "extensions.pocket.enabled" = false;
    "extensions.screenshots.disabled" = true;
    "extensions.blocklist.enabled" = false;
    "extensions.update.autoUpdateDefault" = false;
    "extensions.systemAddon.update.enabled" = false;
    "extensions.systemAddon.update.url" = "";
    "extensions.update.enabled" = false;
    "extensions.autoDisableScopes" = 0;
    "identity.fxaccounts.enabled" = false;
    "identity.fxaccounts.telemetry.clientAssociationPing.enabled" = false;

    # Telemetry / Data collection / Crash reporting
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.prompted" = 2;
    "toolkit.telemetry.rejected" = true;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.unifiedIsOptIn" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "app.shield.optoutstudies.enabled" = false;
    "browser.ping-centre.telemetry" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.sessions.current.clean" = true;
    "devtools.onboarding.telemetry.logged" = false;
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;
    "toolkit.coverage.endpoint.base" = "";
    "toolkit.coverage.opt-out" = true;
    "toolkit.telemetry.coverage.opt-out" = true;
    "browser.region.update.enabled" = false;
    "browser.region.network.url" = "";
    "browser.aboutHomeSnippets.updateUrl" = "";
    "browser.selfsupport" = false;

    # Safe browsing (disabled for pentesting)
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

    # First-run annoyances
    "browser.disableResetPrompt" = true;
    "browser.download.panel.shown" = true;
    "browser.feeds.showFirstRunUI" = false;
    "browser.messaging-system.whatsNewPanel.enabled" = false;
    "browser.rights.3.shown" = true;
    "browser.shell.defaultBrowserCheckCount" = 1;
    "browser.uitour.enabled" = false;
    "startup.homepage_override_url" = "";
    "startup.homepage_welcome_url.additional" = "";
    "trailhead.firstrun.didSeeAboutWelcome" = true;
    "browser.contentblocking.introCount" = 99;
    "browser.pagethumbnails.capturing_disabled" = true;
    "browser.startup.homepage_override.mstone" = "ignore";

    # Recommendations
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
    "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
    "extensions.ui.lastCategory" = "about:addons";

    # Warnings
    "browser.tabs.warnOnClose" = false;
    "browser.tabs.warnOnCloseOtherTabs" = false;
    "browser.tabs.warnOnOpen" = false;
    "browser.warnOnQuit" = false;

    # Popup restrictions
    "browser.link.open_newwindow.restriction" = 0;

    # Downloads
    "browser.download.useDownloadDir" = false;

    # DevTools
    "devtools.selfxss.count" = 50;

    # Network / Privacy
    "browser.vpn_promo.enabled" = false;
    "app.normandy.enabled" = false;
    "extensions.webextensions.restrictedDomains" = "";
    "network.connectivity-service.enabled" = false;
    "browser.search.geoip.url" = "";

    # Cookie banners
    "cookiebanners.service.mode" = 2;
    "cookiebanners.service.mode.privateBrowsing" = 2;

    # Media autoplay
    "media.autoplay.default" = 5;
    "dom.security.https_only_mode" = false;
    "dom.serviceWorkers.enabled" = false;

    # DNS over HTTPS
    "network.trr.mode" = if cfg.dnsProvider == "none" then 5 else 2;
    "network.trr.uri" = dnsProviderUri.${cfg.dnsProvider};
    "network.trr.wait-for-portal" = true;
    "network.dns.echconfig.enabled" = true;
    "network.dns.http3_echconfig.enabled" = true;
    "security.OCSP.enabled" = 0;

    # Prefetch
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = true;

    # WebRTC
    "media.peerconnection.ice.default_address_only" = true;

    # Geolocation
    "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";

    # Forms / Autofill
    "signon.rememberSignons" = false;
    "signon.autofillForms" = false;
    "signon.autofillForms.http" = false;
    "signon.showAutoCompleteFooter" = false;
    "signon.management.page.breach-alerts.enabled" = false;
    "signon.generation.enabled" = false;
    "browser.formfill.enable" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "extensions.formautofill.heuristics.enabled" = false;
    "signon.formlessCapture.enabled" = false;
    "network.auth.subresource-http-auth-allow" = 1;

    # Hardware acceleration
    "media.hardware-video-decoding.enabled" = true;
    "media.hardware-video-decoding.force-enabled" = true;
    "media.ffmpeg.vaapi.enabled" = true;
    "media.rdd-vpx.enabled" = true;
    "widget.dmabuf.force-enabled" = true;
    "webgl.enable-debug-renderer-info" = false;
    "network.http.speculative-parallel-limit" = 0;

    # XDG portal
    "widget.use-xdg-desktop-portal.file-picker" = 1;

    # Network performance
    "network.http.pipelining" = true;
    "network.http.proxy.pipelining" = true;
    "network.http.pipelining.maxrequests" = 32;
    "network.http.max-connections" = 900;
    "network.http.max-persistent-connections-per-server" = 10;
    "network.http.max-persistent-connections-per-proxy" = 10;

    # Rendering
    "content.notify.interval" = 50;
    "content.notify.ontimer" = true;
    "content.interrupt.parsing" = true;
    "content.max.tokenizing.time" = 3000;
    "content.switch.threshold" = 250000;
    "nglayout.initialpaint.delay" = 0;

    # Scrolling
    "apz.overscroll.enabled" = true;

    # HTB domain support (pentesting)
    "browser.fixup.domainsuffixwhitelist.htb" = true;
    "browser.urlbar.trimURLs" = false;

    # Toolbar layout with extension button order
    "browser.uiCustomization.state" = builtins.toJSON {
      placements = {
        nav-bar = [
          "back-button"
          "forward-button"
          "stop-reload-button"
          "customizableui-special-spring1"
          "vertical-spacer"
          "urlbar-container"
          "customizableui-special-spring2"
          "downloads-button"
          "fxa-toolbar-menu-button"
          "${sanitize addons.ublock-origin.addonId}-browser-action"
          "${sanitize addons.bitwarden.addonId}-browser-action"
          "${sanitize addons.pwnfox.addonId}-browser-action"
          "${sanitize addons.darkreader.addonId}-browser-action"
          "${sanitize addons.wappalyzer.addonId}-browser-action"
          "${sanitize addons.bypass-paywalls-clean.addonId}-browser-action"
          "${sanitize addons.cookie-editor.addonId}-browser-action"
          "${sanitize addons.hacktools.addonId}-browser-action"
          "${sanitize addons.simple-modify-header.addonId}-browser-action"
        ];
      };
    };
  };

  baseUserChrome = ''
    /* Remove the "Show sidebars" button everywhere */
    #sidebar-button,
    toolbarpaletteitem > #sidebar-button {
      display: none !important;
    }
  '';

  mergedUserChrome = baseUserChrome + "\n" + cfg.extraUserChrome;

  # Scroll tuning settings (touchpad/APZ)
  scrollTuningSettings = lib.optionalAttrs cfg.enableScrollTuning {
    "apz.gtk.kinetic_scroll.enabled" = true;
    "apz.gtk.kinetic_scroll.delta_mode" = 2;
    "apz.gtk.pangesture.delta_mode" = 2;
    "apz.gtk.kinetic_scroll.pixel_delta_mode_multiplier" = 20;
    "apz.gtk.pangesture.pixel_delta_mode_multiplier" = 20;
    "apz.gtk.touchpad_hold.enabled" = false;
    "general.smoothScroll" = true;
    "general.smoothScroll.msdPhysics.enabled" = true;
    "apz.fling_friction" = 0.012;
    "apz.fling_min_velocity_threshold" = 4.0;
    "layout.frame_rate.precise" = true;
  };

  # AI blocking settings
  aiBlockingSettings = lib.optionalAttrs cfg.enableAIBlocking {
    "browser.ai.control.default" = "blocked";
    "browser.ai.control.linkPreviewKeyPoints" = "blocked";
    "browser.ai.control.pdfjsAltText" = "blocked";
    "browser.ai.control.sidebarChatbot" = "blocked";
    "browser.ai.control.smartTabGroups" = "blocked";
    "browser.ai.control.translations" = "blocked";
    "browser.aiwindow.enabled" = false;
    "browser.ml.enable" = false;
    "browser.ml.chat.enabled" = false;
    "browser.ml.chat.hideFromLabs" = false;
    "browser.ml.chat.hideLabsShortcuts" = false;
    "browser.ml.chat.page" = false;
    "browser.ml.chat.page.footerBadge" = false;
    "browser.ml.chat.page.menuBadge" = false;
    "browser.ml.chat.menu" = false;
    "browser.ml.chat.sidebar" = false;
    "browser.ml.linkPreview.enabled" = false;
    "browser.ml.pageAssist.enabled" = false;
    "browser.ml.smartAssist.enabled" = false;
    "browser.tabs.groups.smart.enabled" = false;
    "browser.tabs.groups.smart.userEnabled" = false;
    "browser.tabs.groups.smart.userEnable" = false;
    "browser.search.visualSearch.featureGate" = false;
    "browser.urlbar.quicksuggest.mlEnabled" = false;
    "browser.translations.enable" = false;
    "extensions.ml.enabled" = false;
    "pdfjs.enableAltText" = false;
    "places.semanticHistory.featureGate" = false;
  };

  # Aggressive acceleration settings
  aggressiveAccelerationSettings = lib.optionalAttrs cfg.aggressiveAcceleration {
    "gfx.webrender.all" = true;
    "gfx.webgpu.ignore-blocklist" = true;
    "dom.webgpu.enabled" = true;
    "gfx.webrender.compositor" = true;
    "gfx.webrender.compositor.force-enabled" = true;
    "gfx.webrender.layer-compositor" = true;
    "gfx.webrender.precache-shaders" = true;
    "layers.force-active" = true;
    "layers.acceleration.disabled" = false;
    "layers.acceleration.force-enabled" = true;
    "gfx.canvas.accelerated" = true;
    "gfx.canvas.accelerated.aa-stroke.enabled" = true;
    "gfx.canvas.accelerated.async-present" = true;
    "gfx.canvas.accelerated.force-enabled" = true;
    "widget.wayland.opaque-region.enabled" = false;
    "webgl.force-enabled" = true;
    "layers.offmainthreadcomposition.enabled" = true;
    "layers.offmainthreadcomposition.async-animations" = true;
    "layers.async-video.enabled" = true;
    "html5.offmainthread" = true;
  };

  # Base extensions from NUR
  baseExtensionPackages = [
    addons.bitwarden
    addons.bypass-paywalls-clean
    addons.cookie-editor
    addons.darkreader
    addons.hacktools
    addons.pwnfox
    addons.simple-modify-header
    addons.simple-translate
    addons.ublock-origin
    addons.wappalyzer
  ];

  # Base extension settings
  baseExtensionSettings = {
    # uBlock Origin - comprehensive filter lists
    "${addons.ublock-origin.addonId}".settings = {
      selectedFilterLists = [
        "user-filters"
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-quick-fixes"
        "ublock-unbreak"
        "easylist"
        "adguard-generic"
        "easyprivacy"
        "adguard-spyware-url"
        "urlhaus-1"
        "curben-phishing"
        "plowe-0"
        "fanboy-cookiemonster"
        "ublock-cookies-easylist"
        "adguard-cookies"
        "ublock-cookies-adguard"
        "easylist-chat"
        "easylist-newsletters"
        "easylist-notifications"
        "easylist-annoyances"
        "adguard-other-annoyances"
        "adguard-popup-overlays"
        "adguard-widgets"
        "ublock-annoyances"
        "DEU-0"
      ];
    };
    # Cookie-Editor - disable ads
    "${addons.cookie-editor.addonId}" = {
      force = true;
      settings.all_options.adsEnabled = false;
    };
    # PwnFox - enable with Burp proxy container
    "${addons.pwnfox.addonId}" = {
      force = true;
      settings = {
        enabled = true;
        useBurpProxyContainer = true;
        removeSecurityHeaders = true;
      };
    };
    # Wappalyzer - accept terms, disable tracking, dark theme
    "${addons.wappalyzer.addonId}" = {
      force = true;
      settings = {
        termsAccepted = true;
        tracking = false;
        version = 1;
        upgradeMessage = false;
        theme = "dark";
      };
    };
    # Bypass Paywalls Clean - opt-in
    "${addons.bypass-paywalls-clean.addonId}" = {
      force = true;
      settings = {
        optInShown = true;
        customShown = true;
        fetchShown = true;
        optInFetch = true;
        optIn = true;
        customOptIn = true;
        optInUpdate = false;
        sites."placeholder" = "#####";
      };
    };
  };
in
{
  options.custom.firefox = {
    enable = lib.mkEnableOption "custom firefox configuration";

    profile = lib.mkOption {
      type = lib.types.enum [ "security" "streaming" ];
      default = "security";
      description = "Firefox profile type (security or streaming).";
    };

    dnsProvider = lib.mkOption {
      type = lib.types.enum [ "cloudflare" "mullvad" "none" ];
      default = "cloudflare";
      description = "DNS over HTTPS provider.";
    };

    processCount = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "DOM IPC process count.";
    };

    aggressiveAcceleration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable aggressive GPU acceleration (WebGPU, force-enabled layers, etc).";
    };

    enableScrollTuning = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable touchpad/APZ scroll tuning.";
    };

    enableAIBlocking = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable Firefox AI features.";
    };

    extraExtensionPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional NUR firefox-addons extension packages to install.";
    };

    extraExtensionSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "Additional extension settings (keyed by addon ID).";
    };

    extraPolicyExtensions = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "Additional extensions to install via Firefox policy (for addons not in NUR).";
    };

    extraUserChrome = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional userChrome.css content for Firefox.";
    };

    bookmarks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Bookmarks to add to the toolbar.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure profiles.ini is writable
    home.activation.ensureWritableFirefoxProfilesIni = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      set -euo pipefail
      ff_dir="$HOME/.mozilla/firefox"
      profiles_ini="$ff_dir/profiles.ini"

      mkdir -p "$ff_dir"

      if [ -L "$profiles_ini" ]; then
        tmp="$(mktemp)"
        cp -aL "$profiles_ini" "$tmp" || true
        rm -f "$profiles_ini"
        if [ -s "$tmp" ]; then
          cat "$tmp" > "$profiles_ini"
        else
          : > "$profiles_ini"
        fi
        rm -f "$tmp"
      fi

      if [ ! -s "$profiles_ini" ]; then
        cat > "$profiles_ini" <<EOF
      [General]
      Version=2
      StartWithLastProfile=1

      [Profile0]
      Name=${config.programs.firefox.profiles.redflake.name or "Red-Flake"}
      IsRelative=1
      Path=${config.programs.firefox.profiles.redflake.path or "redflake"}
      Default=1
      EOF
      fi

      chmod u+rw "$profiles_ini" || true
    '';

    # Fix profile directory
    home.activation.fixFirefoxProfileDir = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      profile_dir="$HOME/.mozilla/firefox/${config.programs.firefox.profiles.redflake.path or "redflake"}"
      if [ -e "$profile_dir" ] && [ ! -d "$profile_dir" ]; then
        backup="$profile_dir.hm-backup-$(date +%s)"
        echo "Home Manager: '$profile_dir' is not a directory; moving it to '$backup'..."
        mv "$profile_dir" "$backup"
      fi
    '';

    programs.firefox = {
      enable = true;
      languagePacks = [ "en-US" ];
      package = pkgs.firefox-bin;

      profiles.redflake = {
        id = 0;
        name = "Red-Flake";
        isDefault = true;
        path = "redflake";

        userChrome = mergedUserChrome;

        search = {
          default = "google";
          privateDefault = "google";
          force = true;
          order = [ "google" ];
          engines = {
            "google" = {
              urls = [{ template = "https://www.google.com/search?q={searchTerms}&hl=en"; }];
              icon = "https://www.google.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@go" ];
            };
          };
        };

        settings =
          baseSettings
          // scrollTuningSettings
          // aiBlockingSettings
          // aggressiveAccelerationSettings;

        bookmarks = {
          force = true;
          settings = [
            {
              name = "toolbar";
              toolbar = true;
              inherit (cfg) bookmarks;
            }
          ];
        };

        extensions = {
          force = true;
          packages = baseExtensionPackages ++ cfg.extraExtensionPackages;
          settings = baseExtensionSettings // cfg.extraExtensionSettings;
        };
      };

      policies = {
        # Updates & Background Services
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;

        # Telemetry & Data Collection
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;

        # Disable useless features
        DisableMasterPasswordCreation = true;
        DisableProfileImport = true;
        DisableProfileRefresh = true;

        # Disable AI
        GenerativeAI = {
          Enabled = false;
          Chatbot = false;
          LinkPreviews = false;
          TabGroups = false;
          Translations = false;
          Locked = true;
        };

        # Nice to haves
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        HardwareAcceleration = true;
        DisplayMenuBar = "default-off";
        SearchBar = "unified";
        OfferToSaveLogins = false;

        # Policy-based extensions (for addons not available in NUR)
        ExtensionSettings =
          {
            "plasma-browser-integration@kde.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
              installation_mode = "force_installed";
            };
            "{ce25b613-ecd1-47e0-9492-c0260efb633c}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/google-sign-in-popup-blocker/latest.xpi";
              installation_mode = "force_installed";
            };
            "default-compact-dark-theme@glitchii.github.io" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/default-compact-dark-theme/latest.xpi";
              installation_mode = "force_installed";
            };
          }
          // cfg.extraPolicyExtensions;
      };
    };
  };
}
