{ config, lib, pkgs, ... }:
{
    # https://home-manager-options.extranix.com/?query=thefuck&release=master
    programs = {
          thefuck = {
            # enable thefuck
            enable = true;
            # enable Zsh integration
            enableZshIntegration = true;
          };
    };
}