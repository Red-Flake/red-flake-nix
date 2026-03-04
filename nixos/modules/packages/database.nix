{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sqlitebrowser
    dbeaver-bin
    sqlmap
    mariadb
    sqlcmd
    sqsh
    mdbtools
  ];
}
