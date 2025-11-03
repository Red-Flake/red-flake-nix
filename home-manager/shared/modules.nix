# Shared module sets for different user types
{ inputs, ... }:
let
  # Common modules that all users need  
  baseModules = [
    ./base.nix
    ../common/modules/git.nix
    ../common/modules/zsh.nix
    ../common/modules/fastfetch.nix
    ../common/modules/flatpak.nix
    ../common/modules/ssh-agent.nix
    ../common/modules/ssh-config.nix
  ];

  # Desktop-specific modules for GUI users
  desktopModules = [
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.nixcord.homeModules.nixcord
    ../common/modules/dconf.nix
    ../common/modules/artwork.nix
    ../common/modules/theme.nix
    ../common/modules/kwallet.nix
    ../common/modules/konsole.nix
    ../common/modules/firefox.nix
    ../common/modules/psd.nix
    ../common/modules/virtualisation.nix
    ../common/modules/desktop-files.nix
    ../common/modules/xdg.nix
    ../common/modules/bat.nix
    ../common/modules/services.nix
    ../common/modules/direnv.nix
    ../common/modules/vesktop.nix
    ../common/modules/vscode.nix
    ../common/modules/plasma-manager.nix
  ];

  # Security/Red Team specific modules
  securityModules = [
    ../common/modules/msf.nix
    ../common/modules/bloodhound.nix
    ../common/modules/burpsuite.nix
    ../common/modules/jadx.nix
  ];
in
{
  # Module sets for different user types
  minimal = baseModules;
  
  desktop = baseModules ++ desktopModules;
  
  security = baseModules ++ desktopModules ++ securityModules;
  
  # For server/cloud users
  server = baseModules ++ [
    ../common/modules/msf.nix
  ];
}