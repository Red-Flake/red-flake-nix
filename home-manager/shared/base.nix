# Shared base home-manager configuration
{ user
, ...
}:
{
  home = {
    # set username and directory from passed parameters
    username = "${user}";
    homeDirectory = "/home/${user}";

    # consistent state version across all configs
    stateVersion = "23.05";

    # disable warning about mismatched version between Home Manager and Nixpkgs
    enableNixpkgsReleaseCheck = false;
  };

  # this is required for NixOS home-manager to work!
  programs.home-manager.enable = false;
}
