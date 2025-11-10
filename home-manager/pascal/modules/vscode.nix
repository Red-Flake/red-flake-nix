{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.vscode = {
    enable = true;

    # fix issue with duplicate vscode icon in task bar due to code-url-handler
    # see: https://github.com/NixOS/nixpkgs/issues/391341#issuecomment-3016213912
    package = pkgs.vscode.overrideAttrs (
      finalAttrs: prevAttrs: {
        desktopItems = lib.map (
          item:
          if item.meta.name == "code-url-handler.desktop" then
            item.overrideAttrs (
              final: prev: {
                text = lib.replaceStrings [ "StartupWMClass=Code\n" ] [ "" ] prev.text;
              }
            )
          else
            item
        ) prevAttrs.desktopItems;
      }
    );

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
          arrterian.nix-env-selector # select nix-env / nix-shell for projects
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

          # --- AI ---
          github.copilot # GitHub Copilot AI pair programmer
          anthropic.claude-code # Claude Code AI integration
        ];

        # set user settings
        userSettings = {
          # This property will be used to generate settings.json:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          "update.channel" = "none";
          "[nix]"."editor.tabSize" = 2;
          "editor.formatOnSave" = true;
          "workbench.colorTheme" = "Catppuccin Mocha";
          "powershell.powerShellAdditionalExePaths"."Downloaded PowerShell" = lib.getExe pkgs.powershell;
          "powershell.powerShellAdditionalExePaths"."Built PowerShell" = lib.getExe pkgs.powershell;
        };

        # set keybindings
        # keybindings = [
        #   # See https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization
        #   {
        #       key = "shift+cmd+j";
        #       command = "workbench.action.focusActiveEditorGroup";
        #       when = "terminalFocus";
        #   }
        # ];
      };
    };

  };
}
