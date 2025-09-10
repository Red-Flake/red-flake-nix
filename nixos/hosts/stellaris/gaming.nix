{
  config,
  inputs,
  pkgs,
  lib,
  chaotic,
  chaoticPkgs,
  modulesPath,
  user,
  ...
}:
let
  gaming = inputs.nix-gaming;
in
{
  imports = with gaming.nixosModules; [
    # https://github.com/fufexan/nix-gaming#platform-optimizations
    pipewireLowLatency
    platformOptimizations
  ];

  # Switch to mesa-git
  #chaotic.mesa-git.fallbackSpecialisation = lib.mkForce false;
  #chaotic.mesa-git.enable = lib.mkForce true;

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
      chaoticPkgs.proton-cachyos_x86_64_v3
    ];

    extest.enable = true;

    protontricks = {
      enable = true;
      package = pkgs.protontricks;
    };

    # use custom environment variables and libraries for steam
    package = lib.mkDefault (
      pkgs.steam.override (prev: {
        extraEnv = {
          MANGOHUD = "0";
          OBS_VKCAPTURE = "1";
          RADV_TEX_ANISO = "16";
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${user}/.steam/root/compatibilitytools.d";
          WINENTSYNC = "1";
          WINEESYNC = "0";
          WINEFSYNC = "0";
          RADV_FORCE_VRS = "1x2";
          RADV_DEBUG = "novrsflatshading";
          RADV_PERFTEST = "nggc,sam,gpl";
          DXVK_ASYNC = "1";
          STEAM_FORCE_DESKTOPUI_SCALING = "2";
          XCURSOR_SIZE = "36";
        }
        // (prev.extraEnv or { });

        extraLibraries =
          pkgs:
          (with pkgs; [
            atk
            libGLU
            sdl2-compat
          ])
          ++ (prev.extraLibraries or [ ]);
      })
    );
  };

  # https://nixos.wiki/wiki/Games
  # Adding programs.nix-ld = { enable = true; libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs; }; to your configuration to run nearly any binary by including all of the libraries used by Steam. (https://old.reddit.com/r/NixOS/comments/1d1nd9l/walking_through_why_precompiled_hello_world/)
  # FIX: error: expected a set but found a list: https://discourse.nixos.org/t/programs-nix-ld-libraries-expects-set-instead-of-list/56009/3?utm_source=chatgpt.com
  programs.nix-ld = {
    enable = true;
    libraries = pkgs.steam-run.args.multiPkgs pkgs;
  };

  # Enable Gamescope Compositor
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Enable GameMode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto"; # Enables SCHED_RR for low latency
        renice = 15; # Higher priority for game processes
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility"; # Allow GPU tweaks
        gpu_device = 2; # Use discrete GPU (1 = integrated, 2 = discrete); see: => /sys/class/drm/card2/device/
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  # see https://github.com/fufexan/nix-gaming/#pipewire-low-latency
  services.pipewire.lowLatency.enable = true;

  environment.sessionVariables = {
    MANGOHUD = "0";
    OBS_VKCAPTURE = "1";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    WINENTSYNC = "1"; # Enable ntsync for best compatibility/performance
    WINEESYNC = "0"; # Disable esync to avoid conflicts
    WINEFSYNC = "0"; # Disable fsync to avoid conflicts
    DXVK_ASYNC = "1"; # Display frames even if they are not completely rendered. This will reduce stuttering a lot, but it could theoretically trigger anti cheat, even though this never actually happened. Your DXVK version needs to be compatible or patched to use it. Proton-GE, until version 7-44, is compatible. For Non-Steam games you can't use Proton, and need a patched DXVK-Version. For Lutris you need to copy it to ~/.local/share/lutris/runtime/dxvk/, and manually select the version inside Lutris (if you named the folder dxvk-async-1.3, you also need to manually type dxvk-async-1.3 in the field).
  };
}
