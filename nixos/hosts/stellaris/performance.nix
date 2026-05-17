{ config
, lib
, ...
}:

{
  # Keep the red-team DB stack running, but reduce its impact on desktop latency
  # by putting it into a low-weight slice + lowering CPU/IO priority.
  systemd.slices.db-background = {
    description = "Background database/services slice (desktop latency first)";
    sliceConfig = {
      CPUWeight = 25;
      IOWeight = 25;
    };
  };

  systemd.services.neo4j = lib.mkIf (config.services.neo4j.enable or false) {
    serviceConfig = {
      Slice = "db-background.slice";
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.services.postgresql = lib.mkIf (config.services.postgresql.enable or false) {
    serviceConfig = {
      Slice = "db-background.slice";
      Nice = 5;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.services."bloodhound-ce" = lib.mkIf
    (
      (config.services ? "bloodhound-ce") && (config.services."bloodhound-ce".enable or false)
    )
    {
      serviceConfig = {
        Slice = "db-background.slice";
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };
    };

  # Enable ZRAM swap for better responsiveness
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 25; # 24GB ZRAM = 48-72GB effective with lz4 ~2-3x compression
    priority = 100; # Higher priority than disk swap
  };

  # NOTE: earlyoom is disabled in hardware.nix for this host
  # With 96GB RAM + 96GB ZRAM, 5% threshold is too aggressive

  # DBus service that provides power management support to applications
  services.upower.enable = true;

  # Ananicy-cpp: auto-prioritize processes (games high, background low)
  # Disable to prevent conflicts with scx scheduler, which already optimizes for desktop responsiveness
  #services.ananicy = {
  #  enable = true;
  #  package = pkgs.ananicy-cpp;
  #  rulesProvider = pkgs.ananicy-rules-cachyos;
  #  settings = {
  #    apply_nice = true;
  #  };
  #};

  # Host-specific sched_ext configuration for Stellaris (Core Ultra 9 275HX + RTX 5070 Ti)
  services.scx = {
    enable = lib.mkForce false; # Disable sched_ext in favor of BORE scheduler for better desktop responsiveness

    # scx_bpfland: Best for desktop/KDE + occasional gaming
    # - Designed for interactive workloads and desktop responsiveness
    # - Handles hybrid P/E-core CPUs well
    # - More stable than LAVD
    scheduler = "scx_bpfland";

    # Low Latency mode: -m performance -w
    # Lowers latency at cost of throughput, good for desktop/gaming/audio
    extraArgs = [
      "-m"
      "performance"
      "-w" # Wake sync for lower latency
    ];
  };
}
