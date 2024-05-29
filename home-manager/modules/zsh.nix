{ config, lib, pkgs, ... }:
let
  # load the configuration that we was generated the first
  # time zsh were loaded with powerlevel enabled.
  # Make sure to comment this part (and the sourcing part below)
  # before you ran powerlevel for the first time or if you want to run
  # again 'p10k configure'. Then, copy the generated file as:
  # $ mv ~/.p10k.zsh p10k-config/p10k.zsh
  configThemeNormal = "p10k.zsh";
  configThemeTTY = "p10k-portable.zsh";
in
{
  fonts.fontconfig.enable = true;

    programs = {
          zsh = {
                ## See options: https://nix-community.github.io/home-manager/options.xhtml

                # enable zsh
                enable = true;

                # Enable zsh completion.
                enableCompletion = true;

                # Enable zsh autosuggestions
                autosuggestion.enable = true;

                # Enable zsh syntax highlighting.
                syntaxHighlighting.enable = true;

                # Commands that should be added to top of {file}.zshrc.
                initExtraFirst = ''
                  # The powerlevel theme I'm using is distgusting in TTY, let's default
                  # to something else
                  # See https://github.com/romkatv/powerlevel10k/issues/325
                  # Instead of sourcing this file you could also add another plugin as
                  # this, and it will automatically load the file for us
                  # (but this way it is not possible to conditionally load a file)
                  # {
                  #   name = "powerlevel10k-config";
                  #   src = lib.cleanSource ./p10k-config;
                  #   file = "p10k.zsh";
                  # }
                  if zmodload zsh/terminfo && (( terminfo[colors] >= 256 )); then
                    [[ ! -f ${configThemeNormal} ]] || source ${configThemeNormal}
                  else
                    [[ ! -f ${configThemeTTY} ]] || source ${configThemeTTY}
                  fi
                '';

                # Extra commands that should be added to {file}.zshrc.
                initExtra = "
                    # disable nomatch to fix weird compatility issues with bash
                    setopt +o nomatch
                ";

                plugins = [
                  {
                    # A prompt will appear the first time to configure it properly
                    # make sure to select MesloLGS NF as the font in Konsole
                    name = "powerlevel10k";
                    src = pkgs.zsh-powerlevel10k;
                    file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                  }
                  {
                    name = "powerlevel10k-config";
                    src = ./p10k-config;
                    file = "${configThemeNormal}";
                  }
                ];

                oh-my-zsh = {
                    # enable oh-my-zsh
                    enable = true;

                    plugins = [
                        "git"
                        "docker"
                        "colorize"
                        "colored-man-pages"
                        "sudo"
                        "z"
                    ];

                };

                # define shell aliases which are substituted anywhere on a line
                # https://home-manager-options.extranix.com/?query=programs.zsh.shellAliase
                shellGlobalAliases = {
                    ls = "lsd";
                    ll = "lsd -la";
                    la = "lsd -la";
                    lsa = "lsd -la";
                    cat = "bat";
                    cme = "nxc";
                    crackmapexec = "netexec";
                };

      };
   };  
}
