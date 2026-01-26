{ pkgs
, ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    evil-winrm
    evil-winrm-py
    openssh
    freerdp
    rdesktop
    remmina
    moonlight-qt
  ];
}
