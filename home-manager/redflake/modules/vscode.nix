{ config, lib, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # set profiles
    profiles = {
      default = {

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
        ];
      };
    };
    
  };
}