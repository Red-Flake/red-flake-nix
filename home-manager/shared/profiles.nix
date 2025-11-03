# User profiles with specific configurations
{ inputs, pkgs, lib, ... }:
let
  packages = import ./packages.nix { inherit pkgs; };
in
{
  # Profile for Mag1cByt3s (security researcher) 
  mag1cbyt3s = {
    git = {
      userName = "Mag1cByt3s";
      userEmail = "ppeinecke@protonmail.com";
      signing = null; # No signing
    };
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
    modules = [
      ./base.nix
      ../common/modules/git.nix
      ../common/modules/zsh.nix
      ../common/modules/fastfetch.nix
      ../common/modules/flatpak.nix
      ../common/modules/ssh-agent.nix
      ../common/modules/ssh-config.nix
      # Desktop modules
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
      # Security modules
      ../common/modules/msf.nix
      ../common/modules/bloodhound.nix
      ../common/modules/burpsuite.nix
      ../common/modules/jadx.nix
    ];
    packages = packages.base ++ packages.desktop ++ packages.gaming ++ packages.development;
  };

  # Profile for Letgamer (gaming/desktop user)
  letgamer = {
    git = {
      userName = "Letgamer";
      userEmail = "alexstephan005@gmail.com";
      signing = {
        key = "~/.ssh/id_redline-ssh.pub";
        signByDefault = true;
        format = "ssh";
      };
    };
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
    modules = [
      ./base.nix
      ../common/modules/git.nix
      ../common/modules/zsh.nix
      ../common/modules/fastfetch.nix
      ../common/modules/flatpak.nix
      ../common/modules/ssh-agent.nix
      # Desktop modules
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
      # Security modules
      ../common/modules/msf.nix
      ../common/modules/bloodhound.nix
      ../common/modules/burpsuite.nix
      ../common/modules/jadx.nix
      # User-specific modules
      ../redline/modules/ssh-config.nix
      ../redline/modules/monitors.nix
    ];
    packages = packages.base ++ packages.desktop ++ packages.gaming ++ packages.networking;
  };

  # Profile for redcloud (minimal server user)
  redcloud = {
    git = {
      userName = "Mag1cByt3s";
      userEmail = "ppeinecke@protonmail.com";
      signing = null;
    };
    sessionVariables = {};
    modules = [
      ./base.nix
      ../common/modules/git.nix
      ../common/modules/zsh.nix
      ../common/modules/fastfetch.nix
      ../common/modules/flatpak.nix
      ../common/modules/ssh-agent.nix
      ../common/modules/ssh-config.nix
      ../common/modules/msf.nix
    ];
    packages = packages.base;
  };
}