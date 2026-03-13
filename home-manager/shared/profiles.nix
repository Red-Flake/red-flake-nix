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
    ../common/modules/zsh.nix
    ../common/modules/fastfetch.nix
    ../common/modules/ssh-agent.nix
    ../common/modules/starship.nix
  ];

  # Base modules for desktop profiles (adds flatpak to core)
  # Note: ssh-config.nix is added per-profile since letgamer has a custom version
  baseDesktopModules = coreModules ++ [
    ../common/modules/flatpak.nix
  ];

  # Desktop environment modules (KDE Plasma, theming, etc.)
  desktopEnvModules = [
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
    ../common/modules/filezilla.nix
  ];

  # Security tool modules
  securityModules = [
    ../common/modules/msf.nix
    ../common/modules/bloodhound.nix
    ../common/modules/burpsuite.nix
    ../common/modules/jadx.nix
  ];

  # Full desktop profile modules (base + desktop env + security)
  fullDesktopModules = baseDesktopModules ++ desktopEnvModules ++ securityModules;

  # Common session variables for desktop users
  commonDesktopSessionVars = {
    MOZ_ENABLE_WAYLAND = 1;
    XCURSOR_SIZE = "24";
  };

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
      ../common/modules/ghostty.nix
      ../common/modules/firefox.nix
      ../common/modules/equibop.nix
      ../common/modules/vscode.nix
      ../common/modules/plasma-manager.nix
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
      ../common/modules/ghostty.nix
      ../common/modules/firefox.nix
      ../common/modules/equibop.nix
      ../common/modules/vscode.nix
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
      ../common/modules/vesktop.nix
      ../common/modules/vscode.nix
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
      ../common/modules/flatpak.nix
      ../common/modules/ssh-config.nix
      ../common/modules/msf.nix
    ];
    packages = packages.base;
  };
}
