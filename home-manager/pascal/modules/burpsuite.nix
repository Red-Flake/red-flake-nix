{ pkgs
, ...
}: {
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

    license = "vMSW1CwQe66w4Rf1YgqHTv5i7C/u1RjfV9O3ZT55xwGvYAn2zh0uJq9gCfbOHS4mVlbyb7O0fZyFaQcK+3ebZC29Goqrc80aBZR6BQBSNDv52+Jj0f7ZfnzG7ZpnktmX4I0P6f/DcLBEIJ6FSkuJfm5eheOM/xr2Z1hMv7KG35Y16PVjtRuWVfF53QHD5NZaAqexCmRCtZ2/UGTnzsen3LcWNNVb1eWH1uEPcQpVV+LUcGjaDT5mPbYv2RgR6VQFqv/EDPznI4CTRsW309iSfAPUjIqOgNqrOAEO5df8F9zPzwqb4QEyKegEPhnuYmTXCwJc4Q7tj6i4Kk4TgkQm/sydN1nAl6i1jOAE15Bk1Ht/FZuVqEA5p7c8GEiVw4Ge7gJJXijV7elN4TJ2uM23+B8f+87OrOlhGeXmlhbz/glZgADDgllILWXf4kSMqdDuzvdU93esIKDJCODhTel3kHG0d7ZzsNCDt/5SW7SHAvuNFvYuwLDpLLuZcgnVF9iMxJpTlFEsjO2gYL2y92xjtq3sq3hksotq/dd/e1/ET8Bk+wzGrMiuEMjFeiqWvqHlLvLYpXroVseLWba5fEMMA8xwsWj5PkPj0/MHJRgAzFsjlq4oNdblYtmtW92VaMb0RLW+mIfHFoc33Klm1GiGo0eik7I/5j7bgzDn5HhuuVotP0Mn2uXFJ+/sfB926sRRUkYH2n2UxhqzMKROfzcUpg1dz1+m0sV3chEcmYdhYPbL4ThZy3WEuVWXEKLx5DVX5+1zPYsScfXF0i+Qgqy/U9Q5LPd7cJPLOM3Dwqf1TY4=";

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
          font_size = "16";
        };
        http_message_display = {
          # Set HTTP message display font to Monospace for better readability
          font_name = "Monospace";

          # Set HTTP message display font size to 20 for better readability
          font_size = "20";

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
}
