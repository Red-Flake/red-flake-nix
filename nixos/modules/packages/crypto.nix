{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cryptsetup
    keepassxc
    openssl_legacy
    osslsigncode
    veracrypt
  ];
}
