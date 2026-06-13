{ inputs
, pkgs
, lib
, user
, ...
}:
let
  gaming = inputs.nix-gaming;
in
{
  imports = with gaming.nixosModules; [
    # https://github.com/fufexan/nix-gaming#platform-optimizations
    platformOptimizations
  ];

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    extest.enable = false;

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
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${user}/.steam/root/compatibilitytools.d";
          WINENTSYNC = "1";
          WINEESYNC = "0";
          WINEFSYNC = "0";
          STEAM_FORCE_DESKTOPUI_SCALING = "2";
          XCURSOR_SIZE = "36";
          DRI_PRIME = "1"; # Force discrete GPU
          MESA_LOADER_DRIVER_OVERRIDE = "nvidia"; # Force Nvidia driver for steam
          __NV_PRIME_RENDER_OFFLOAD = "1"; # Offload rendering to discrete NVIDIA GPU
          __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Use NVIDIA GLX library
          __VK_LAYER_NV_optimus = "NVIDIA_only"; # Use NVIDIA Vulkan layer
          __VK_DRIVER_ID = "nvidia"; # Use NVIDIA Vulkan driver
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
        gpu_device = 0; # Use discrete GPU (card0 = NVIDIA); see: /sys/class/drm/card0/device/
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

}
