{ pkgs
, ...
}:

{
  # make /etc/hosts writable on demand
  #environment.etc.hosts.mode = "0644";

  # Disable NixOS management of `/etc/hosts`.
  environment.etc."hosts".enable = false;

  # make /etc/hostname writable on demand
  environment.etc.hostname.mode = "0644";

  # enable nix-ld; needed for `nix-alien-ld`
  programs.nix-ld.enable = true;

  # fix issue where dotnet does not find the installed runtime; see: https://nixos.wiki/wiki/DotNET
  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk}";
  };

}
