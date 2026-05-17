# Parameterized sysctl module with options for different host profiles
{ config
, lib
, ...
}:
let
  cfg = config.custom.sysctl;

  # Network buffer sizes scaled by RAM
  # Base: 64MB max for 8GB, scale proportionally
  networkBufferMax =
    if cfg.ramGB >= 96 then 134217728  # 128 MB
    else if cfg.ramGB >= 32 then 67108864  # 64 MB
    else 33554432; # 32 MB for smaller systems

  # Standard sysctl settings shared across all profiles
  standardSysctls = {
    # Swappiness - low for standard, high for ZRAM
    "vm.swappiness" = cfg.swappiness;

    # Adjust cache pressure
    "vm.vfs_cache_pressure" = 30;

    # Dirty page settings
    "vm.dirty_bytes" = 1073741824; # 1 GB
    "vm.dirty_background_bytes" = 268435456; # 256M
    "vm.dirty_writeback_centisecs" = 1000; # 10 seconds

    # Page cluster - 0 for SSD
    "vm.page-cluster" = 0;

    # Allow unprivileged users to bind ports below 1024
    "net.ipv4.ip_unprivileged_port_start" = 0;

    # File system limits
    "fs.inotify.max_user_watches" = 1048576;
    "fs.aio-max-nr" = 1000000;

    # Scheduler settings
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.printk" = "3 3 3 3";
    "kernel.kexec_load_disabled" = 1;
    "kernel.sysrq" = 1;

    # Network settings
    "net.core.somaxconn" = 8192;
    "net.core.netdev_max_backlog" = 65536;
    "net.core.rmem_default" = 1048576;
    "net.core.rmem_max" = networkBufferMax;
    "net.core.wmem_default" = 1048576;
    "net.core.wmem_max" = networkBufferMax;
    "net.ipv4.ipfrag_high_thresh" = 5242880;
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = cfg.qdisc;
  };

  # Core dumps setting
  coreDumpSysctl = lib.optionalAttrs cfg.disableCoreDumps {
    "kernel.core_pattern" = "/dev/null";
  };

  # ZRAM optimizations (high swappiness already set via cfg.swappiness)
  zramSysctls = lib.optionalAttrs cfg.enableZRAMOptimizations {
    # Reserve free RAM for UI bursts (512 MiB for high-RAM systems)
    "vm.min_free_kbytes" = if cfg.ramGB >= 64 then 524288 else 262144;
  };

  # Gaming/workstation tweaks
  gamingSysctls = lib.optionalAttrs cfg.enableGamingTweaks {
    # Increase max memory map areas - required by many games and Electron apps
    "vm.max_map_count" = 1048576;
    # Disable proactive memory compaction to avoid latency spikes
    "vm.compaction_proactiveness" = 0;
    # Disable zone reclaim for desktop
    "vm.zone_reclaim_mode" = 0;
  };

  # Advanced networking tweaks
  advancedNetworkingSysctls = lib.optionalAttrs cfg.enableAdvancedNetworking {
    # TIME-WAIT assassination protection
    "net.ipv4.tcp_rfc1337" = 1;
    # Shorter FIN timeout
    "net.ipv4.tcp_fin_timeout" = 30;
    # Wider ephemeral port range
    "net.ipv4.ip_local_port_range" = "15000 65535";
    # Log weird source addresses
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    # TCP Fast Open
    "net.ipv4.tcp_fastopen" = 3;
    # MTU probing
    "net.ipv4.tcp_mtu_probing" = 1;
  };

  # Security hardening
  securitySysctls = lib.optionalAttrs cfg.enableSecurityHardening {
    # Hide kernel pointers
    "kernel.kptr_restrict" = 2;
    # Watchdog settings
    "kernel.nmi_watchdog" = 1;
    "kernel.watchdog" = 1;
    # Panic on oops
    "kernel.panic_on_oops" = 0;
  };
in
{
  options.custom.sysctl = {
    enable = lib.mkEnableOption "custom sysctl settings";

    profile = lib.mkOption {
      type = lib.types.enum [ "standard" "workstation" ];
      default = "standard";
      description = ''
        Sysctl profile to use:
        - standard: Basic optimized settings for VMs and servers
        - workstation: Full desktop/gaming optimizations (enables gaming tweaks, THP, advanced networking)
      '';
    };

    ramGB = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "System RAM in GB, used for scaling network buffers.";
    };

    swappiness = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Swappiness value. Set high (100) for ZRAM systems.";
    };

    qdisc = lib.mkOption {
      type = lib.types.enum [ "fq" "cake" ];
      default = "fq";
      description = "Default network queuing discipline.";
    };

    disableCoreDumps = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable core dumps by redirecting to /dev/null.";
    };

    enableZRAMOptimizations = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable optimizations for ZRAM (high swappiness, min_free_kbytes).";
    };

    enableGamingTweaks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gaming/desktop tweaks (max_map_count, disable compaction, etc).";
    };

    enableTransparentHugepages = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Transparent Hugepage and MGLRU sysfs settings.";
    };

    enableAdvancedNetworking = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable advanced networking (TCP Fast Open, MTU probing, etc).";
    };

    enableSecurityHardening = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable security hardening (kptr_restrict, watchdogs, panic_on_oops).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Systemd limits
    systemd.settings.Manager = {
      DefaultLimitNOFILE = 1048576;
      DefaultLimitNPROC = 1048576;
    };

    # PAM limits
    security.pam.loginLimits = [
      { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
      { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
      { domain = "*"; type = "soft"; item = "nproc"; value = "1048576"; }
      { domain = "*"; type = "hard"; item = "nproc"; value = "1048576"; }
    ];

    # Sysfs settings for THP/MGLRU (not sysctls)
    systemd.tmpfiles.rules = lib.mkIf cfg.enableTransparentHugepages [
      # Transparent Huge Pages: prefer explicit madvise() (low-latency default)
      "w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise"
      "w /sys/kernel/mm/transparent_hugepage/defrag - - - - madvise"
      # Multi-Gen LRU: keep it enabled
      "w /sys/kernel/mm/lru_gen/enabled - - - - 0x0007"
    ];

    # Combine all sysctl settings
    boot.kernel.sysctl =
      standardSysctls
      // coreDumpSysctl
      // zramSysctls
      // gamingSysctls
      // advancedNetworkingSysctls
      // securitySysctls;
  };
}
