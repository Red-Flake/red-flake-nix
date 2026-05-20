# User profiles with specific configurations
{ inputs
, pkgs
, pkgsUnstable ? pkgs
, homeDirectory
, ...
}:
let
  packages = import ./packages.nix { inherit pkgs pkgsUnstable; };

  # =============================================================================
  # Module Groups (Mixins) - Reusable module sets to avoid duplication
  # =============================================================================

  # Core modules needed by all profiles (including server)
  coreModules = [
    ./base.nix
    ../common/modules/git.nix
    ../pascal/modules/zsh.nix
    ../common/modules/fastfetch.nix
    ../pascal/modules/ssh-agent.nix
    ../pascal/modules/starship.nix
  ];

  # Base modules for desktop profiles (adds flatpak to core)
  # Note: ssh-config.nix is added per-profile since letgamer has a custom version
  baseDesktopModules = coreModules ++ [
    ../pascal/modules/flatpak.nix
  ];

  # Desktop environment modules (KDE Plasma, theming, etc.)
  desktopEnvModules = [
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.nixcord.homeModules.nixcord
    ../pascal/modules/dconf.nix
    ../pascal/modules/artwork.nix
    ../pascal/modules/theme.nix
    ../pascal/modules/kwallet.nix
    ../pascal/modules/konsole.nix
    ../pascal/modules/psd.nix
    ../pascal/modules/virtualisation.nix
    ../pascal/modules/desktop-files.nix
    ../pascal/modules/xdg.nix
    ../pascal/modules/bat.nix
    ../pascal/modules/services.nix
    ../pascal/modules/direnv.nix
    ../pascal/modules/filezilla.nix
  ];

  # Security tool modules
  securityModules = [
    inputs.burpsuite-nix.homeManagerModules.default
    ../pascal/modules/msf.nix
    ../pascal/modules/bloodhound.nix
    ../pascal/modules/burpsuite.nix
    ../pascal/modules/jadx.nix
  ];

  # Full desktop profile modules (base + desktop env + security)
  fullDesktopModules = baseDesktopModules ++ desktopEnvModules ++ securityModules;

  # Common session variables for desktop users
  # Note: MOZ_ENABLE_WAYLAND, NIXOS_OZONE_WL, XCURSOR_SIZE are set system-wide in nixos/modules/kde.nix
  commonDesktopSessionVars = { };

  # Common session path for all users
  commonSessionPath = [
    "${homeDirectory}/.local/bin"
    "${homeDirectory}/go/bin"
  ];

in
{
  # Profile for pascal
  pascal = {
    git = {
      userName = "Mag1cByt3s";
      userEmail = "ppeinecke@protonmail.com";
      signing = {
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
        format = "ssh";
      };
    };
    sessionVariables = commonDesktopSessionVars // {
      MOZ_USE_XINPUT2 = 1;
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${homeDirectory}/.steam/root/compatibilitytools.d";
      TERMINAL = "ghostty +new-window";
    };
    sessionPath = commonSessionPath;
    modules = fullDesktopModules ++ [
      # Pascal-specific modules
      ../common/modules/ssh-config.nix
      ../pascal/modules/ghostty.nix
      ../pascal/modules/firefox.nix
      ../pascal/modules/equibop.nix
      ../pascal/modules/vscode.nix
      ../pascal/modules/plasma-manager.nix
      ../pascal/modules/ucc.nix
    ];
    packages = packages.base ++ packages.desktop ++ packages.gaming ++ packages.development;
  };

  # Profile for Letgamer
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
    sessionVariables = commonDesktopSessionVars;
    sessionPath = commonSessionPath;
    modules = fullDesktopModules ++ [
      # Letgamer-specific modules
      ../pascal/modules/ghostty.nix
      ../let/modules/firefox.nix
      ../let/modules/monitors.nix
      ../let/modules/plasma-manager.nix
      ../let/modules/ssh-config.nix
      ../let/modules/vesktop.nix
      ../let/modules/vscode.nix
    ];
    packages = packages.base ++ packages.desktop ++ packages.gaming ++ packages.networking;
  };

  # Profile for Shanzem
  shanzem = {
    git = {
      userName = "Shanzem";
      userEmail = "owar125@gmail.com";
      signing = {
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
        format = "ssh";
      };
    };
    sessionVariables = commonDesktopSessionVars // {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${homeDirectory}/.steam/root/compatibilitytools.d";
      TERMINAL = "ghostty +new-window";
    };
    sessionPath = commonSessionPath;
    modules = fullDesktopModules ++ [
      # Shanzem-specific modules
      ../common/modules/ssh-config.nix
      ../pascal/modules/ghostty.nix
      ../common/modules/firefox.nix
      ../pascal/modules/equibop.nix
      ../pascal/modules/vscode.nix
      ../shanzem/modules/plasma-manager.nix
    ];
    packages = packages.base ++ packages.desktop ++ packages.gaming ++ packages.development;
  };

  # Profile for redflake (default account)
  redflake = {
    git = {
      userName = "Red Flake";
      userEmail = "redflakeorg@protonmail.com";
      signing = null;
    };
    sessionVariables = commonDesktopSessionVars;
    sessionPath = commonSessionPath;
    modules = fullDesktopModules ++ [
      # Redflake-specific modules
      ../common/modules/ssh-config.nix
      ../common/modules/firefox.nix
      ../pascal/modules/vesktop.nix
      ../pascal/modules/vscode.nix
      ../common/modules/plasma-manager.nix
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
    sessionPath = commonSessionPath;
    modules = coreModules ++ [
      ../pascal/modules/flatpak.nix
      ../common/modules/ssh-config.nix
      ../pascal/modules/msf.nix
    ];
    packages = packages.base;
  };
}
