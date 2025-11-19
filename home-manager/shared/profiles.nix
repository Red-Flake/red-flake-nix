# User profiles with specific configurations
{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  packages = import ./packages.nix { inherit pkgs; };
in
{
  # Profile for pascal (security researcher)
  pascal = {
    git = {
      userName = "Mag1cByt3s";
      userEmail = "ppeinecke@protonmail.com";
      signing = null; # No signing
    };
    sessionVariables = {
      # Enalbe Wayland for Firefox
      MOZ_ENABLE_WAYLAND = 1;

      # Set steam proton path
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\\\${HOME}/.steam/root/compatibilitytools.d";

      # Set terminal to konsole
      TERMINAL = "konsole";

      # Set global xcursor size to 24; this matches the default cursor size in KDE Plasma of 24
      XCURSOR_SIZE = "24";

      # Add ~/.local/bin to PATH
      PATH = "\\\${HOME}/.local/bin:$PATH";
    };
    modules = [
      # Base modules
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

      # Common p10k module (uses pascal's configs)
      ../common/modules/p10k.nix
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
      # Base modules
      ./base.nix
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
      ../common/modules/psd.nix
      ../common/modules/virtualisation.nix
      ../common/modules/desktop-files.nix
      ../common/modules/xdg.nix
      ../common/modules/bat.nix
      ../common/modules/services.nix
      ../common/modules/direnv.nix
      ../common/modules/ssh-config.nix

      # Security modules
      ../common/modules/msf.nix
      ../common/modules/bloodhound.nix
      ../common/modules/burpsuite.nix
      ../common/modules/jadx.nix

      # Common p10k module (uses pascal's configs)
      ../common/modules/p10k.nix

      # User-specific modules
      ../let/modules/firefox.nix
      ../let/modules/monitors.nix
      ../let/modules/plasma-manager.nix
      ../let/modules/ssh-config.nix
      ../let/modules/vesktop.nix
      ../let/modules/vscode.nix
    ];
    packages = packages.base ++ packages.desktop ++ packages.gaming ++ packages.networking;
  };

  # Profile for redflake (default account)
  redflake = {
    git = {
      userName = "Red Flake";
      userEmail = "redflakeorg@protonmail.com";
      signing = null;
    };
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
    modules = [
      # Base modules
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

      # Common p10k module (uses pascal's configs)
      ../common/modules/p10k.nix
    ];
    packages = packages.base ++ packages.desktop ++ packages.gaming ++ packages.development;
  };

  # Profile for redcloud (minimal server user)
  redcloud = {
    git = {
      userName = "Mag1cByt3s";
      userEmail = "ppeinecke@protonmail.com";
      signing = null;
    };
    sessionVariables = { };
    modules = [
      # Base modules
      ./base.nix
      ../common/modules/git.nix
      ../common/modules/zsh.nix
      ../common/modules/fastfetch.nix
      ../common/modules/flatpak.nix
      ../common/modules/ssh-agent.nix
      ../common/modules/ssh-config.nix
      ../common/modules/msf.nix

      # Common p10k module (uses pascal's configs)
      ../common/modules/p10k.nix
    ];
    packages = packages.base;
  };
}
