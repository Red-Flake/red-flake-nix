{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    python312Packages.aiosmtpd
    swaks
    smtp-user-enum
  ];
}
