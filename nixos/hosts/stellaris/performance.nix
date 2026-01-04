{ lib
, pkgs
, ...
}:

{
  # Enable ZRAM swap for better responsiveness
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100; # Use up to 100% of RAM size for ZRAM (compressed)
    priority = 100; # Higher priority than disk swap
  };

  # Enable earlyoom as a safety net to kill processes before the system hangs
  services.earlyoom = {
    enable = true;
    enableNotifications = true; # Notify the user when a process is killed
    freeMemThreshold = 5; # Kill processes if free memory drops below 5%
    freeSwapThreshold = 5; # Kill processes if free swap (ZRAM) drops below 5%
  };

  # Host-specific sched_ext configuration for Stellaris (Core Ultra 9 275HX + RTX 5070 Ti)
  services.scx = {
    enable = false; # Disabled for now due to issues with 100% CPU load on the LAVD scheduler

    # Workaround for https://github.com/NixOS/nixpkgs/issues/441768
    package = pkgs.scx.full.overrideAttrs (old: {
      postPatch = ''
        rm meson-scripts/fetch_bpftool meson-scripts/fetch_libbpf
        patchShebangs ./meson-scripts
        cp ${old.fetchBpftool} meson-scripts/fetch_bpftool
        cp ${old.fetchLibbpf} meson-scripts/fetch_libbpf
        substituteInPlace ./meson-scripts/build_bpftool \
          --replace-fail '/bin/bash' '${lib.getExe pkgs.bash}'
      '';
    });

    # Why choose LAVD on 275HX (P/E hybrid)?
    # - Prioritizes latency and frame-time stability for desktop + gaming (virtual-deadline, futex boost).
    # - Hybrid-aware with core compaction + energy model to prefer P-cores under interactive/mixed load.
    # - Good responsiveness under stress; we let TCC manage frequency to avoid policy conflicts.
    scheduler = "scx_lavd";

    # Let TCC/tccd own CPU frequency; LAVD handles scheduling and P-core preference
    extraArgs = [
      "--performance" # Keeps compaction; enables EM-based CPU preference (P-cores first)
      "--no-freq-scaling" # Avoid conflicts with TCC controlling governors/EPP
      "--slice-min-us"
      "250"
      "--slice-max-us"
      "3000"
      "--preempt-shift"
      "5"
    ];
  };
}
