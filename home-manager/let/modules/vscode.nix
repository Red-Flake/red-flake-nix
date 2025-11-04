{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # disable mutable extensions
    mutableExtensionsDir = false;

    # set profiles
    profiles = {
      default = {

        # disable update check
        enableUpdateCheck = false;

        # disable extension update check
        enableExtensionUpdateCheck = false;

        # set extensions
        extensions = with pkgs.vscode-extensions; [
          # --- Nix / Environment ---
          mkhl.direnv # integrates direnv with VSCode
          bbenoist.nix # basic Nix language support
          oops418.nix-env-picker # select nix-env / nix-shell for projects
          jnoortheen.nix-ide # advanced Nix IDE features (linting, completion)

          # --- Code editing / navigation ---
          christian-kohler.path-intellisense # auto-complete file paths
          formulahendry.auto-rename-tag # auto-rename paired HTML/XML tags
          vscode-icons-team.vscode-icons # nice file icons
          mechatroner.rainbow-csv # colorize CSV columns
          catppuccin.catppuccin-vsc # Catppuccin theme
          catppuccin.catppuccin-vsc-icons # Catppuccin file icons
          esbenp.prettier-vscode # Prettier code formatter
          ms-vscode.hexeditor # Hex editor for binary files
          oderwat.indent-rainbow # colorful indentation
          adpyke.codesnap # code screenshotter
          ibm.output-colorizer # log and output colorizer

          # --- Markdown / Docs ---
          yzhang.markdown-all-in-one # Markdown shortcuts, TOC, auto formatting
          davidanson.vscode-markdownlint # Linting for Markdown

          # --- Git / GitHub ---
          eamodio.gitlens # Git blame/history/insights
          github.vscode-pull-request-github # PR & issue integration with GitHub

          # --- Programming languages ---
          ms-vscode.cpptools # C/C++ IntelliSense & debugging
          ms-python.python # Python language support
          ms-python.vscode-pylance # Python analysis engine (fast autocomplete)
          tamasfe.even-better-toml # TOML syntax highlighting (Rust, configs)
          redhat.vscode-yaml # YAML validation & schema support
          ms-vscode.powershell # PowerShell language support
          rust-lang.rust-analyzer # Rust support
          myriad-dreamin.tinymist # Typst Integration

          # --- Server Management ---
          ms-azuretools.vscode-docker # Docker Extension
          ms-vscode-remote.remote-ssh # Remote SSh to my Server

          # --- AI ---
          github.copilot # GitHub Copilot AI pair programmer
        ];

        # set user settings
        userSettings = {
          # This property will be used to generate settings.json:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          "update.channel" = "none";
          "telemetry.telemetryLevel" = "off";
          "telemetry.feedback.enabled" = false;
          "[nix]"."editor.tabSize" = 2;
          "editor.formatOnSave" = true;
          "workbench.colorTheme" = "Catppuccin Mocha";
          "security.workspace.trust.enabled" = false;
          "remote.SSH.defaultExtensions" = [
            "ms-azuretools.vscode-docker"
            "oderwat.indent-rainbow"
          ];
        };
      };
    };
  };
}
