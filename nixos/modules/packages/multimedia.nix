{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    audacity
    # sonic-visualiser    # sonic-visualiser fails to build...
    mpv
    vlc
  ];
}
