# firefox.nix

{ config, pkgs, inputs, ... }:

{
  programs.firefox = {
    enable = true;

    profiles.pascal = {
  
      isDefault = true;

      bookmarks = [
        {
          name = "RedFlake";
          tags = [ "redflake" ];
          keywords = "redflake";
          url = "https://github.com/red-Flake/";
        }
      ];

      settings = {
        "extensions.update.autoUpdateDefault" = false;
      };

      extensions = with config.nur.repos.rycee.firefox-addons; [
        foxyproxy-standard
        dracula-dark-colorscheme
        darkreader
        wappalyzer
        waybackmachine
        ublock-origin        
      ];

    };
  };

}
