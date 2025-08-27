{ config, lib, pkgs, ... }:
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
          mkhl.direnv
          bbenoist.nix
          arrterian.nix-env-selector
          jnoortheen.nix-ide
          christian-kohler.path-intellisense
          yzhang.markdown-all-in-one
          formulahendry.auto-rename-tag
          vscode-icons-team.vscode-icons
          mechatroner.rainbow-csv
          github.copilot
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
        ];

        # set user settings
        userSettings = {
          # This property will be used to generate settings.json:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          "update.channel" = "none";
          "[nix]"."editor.tabSize" = 2;
          "editor.formatOnSave" = true;
          "workbench.colorTheme" = "Catppuccin Mocha";
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