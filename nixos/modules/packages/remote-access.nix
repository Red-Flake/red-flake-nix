{ inputs
, config
, lib
, pkgs
, modulesPath
, ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    evil-winrm-patched
    inputs.redflake-packages.packages.x86_64-linux.evil-winrm-py
    openssh
    freerdp3
    rdesktop
    remmina
    moonlight-qt
  ];
}
