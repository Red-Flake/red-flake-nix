{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    filezilla
    nfs-utils
    python312Packages.wsgidav
    lftp
  ];
}
