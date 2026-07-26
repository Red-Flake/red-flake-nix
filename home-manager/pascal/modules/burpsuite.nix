{ lib
, pkgs
, ...
}: {
  # Separate Community Edition for e.g. OSCP
  xdg.desktopEntries.burpsuitece = {
    name = "Burp Suite Community Edition";
    exec = "burpsuite --product-mode=community";
    icon = "burpsuite";
    genericName = "Web Application Security Testing Tool";
    categories = [ "Development" "Security" ];
  };

  programs.burp = {
    enable = true;
    proEdition = true;

    wordlists = {
      seclists = "${pkgs.seclists}/share/wordlists/seclists";
    };

    preferences = {
      "suite.override-default-scaling-options" = "true";
      "suite.scale-factor" = "1.75";
    };

    cliArgs = [
      "--suppress-jre-check"
      "--i-accept-the-license-agreement"
      "--disable-auto-update"
      "--disable-check-for-updates-dialog"
      "--temporary-project"
      "--unpause-spider-and-scanner"
    ];

    extensions = {
      # Loaded by default
      "403-bypasser" = { };
      "json-web-tokens" = { };
      "js-miner" = { };
      "param-miner" = { };
      "wsdler" = { };

      # Installed but not loaded
      "http-request-smuggler" = {
        loaded = false;
      };
    };

    # Settings that are deep-merged into the default config
    settings = {
      display = {
        user_interface = {
          # Enable Darkmode
          look_and_feel = "Dark";

          # Set UI font size to 16
          font_size = 16;
        };
        http_message_display = {
          # Set HTTP message display font to Monospace for better readability
          font_name = "Monospace";

          # Set HTTP message display font size to 20 for better readability
          font_size = 20;

          # Enable font smoothing
          font_smoothing = true;

          # Enable syntax highlighting for HTTP requests and responses
          highlight_requests = true;
          highlight_responses = true;

          # Pretty-print JSON and XML by default in the HTTP message viewer
          pretty_print_by_default = true;
        };
        # Disable FlatLaf custom window decorations — let KWin provide
        # server-side decorations instead.
        window_decoration = {
          use_custom_window_decorations = false;
        };
      };
    };
  };

  # Burp 2026.x fails to initialize top-level tools with the fully generated
  # UserConfig.json from burpsuite-nix. Let Burp manage this file itself.
  home.file.".BurpSuite/UserConfig.json".enable = lib.mkForce false;
}
