{ pkgs
, lib
, ...
}:

{
  nixpkgs.overlays = lib.mkAfter [
    (
      final: prev:
        let
          makeXanmodKernel =
            { version
            , hash
            , suffix ? "xanmod1"
            , extraConfig ? { }
            ,
            }:
            let
              ver = version; # expect a full 3-part version like "6.18.0"
              rev = "${lib.versions.pad 3 ver}-${suffix}";
              base = (prev.linuxPackages_xanmod_latest or prev.linuxPackages_xanmod).kernel;
            in
            (base.override {
              # Override arguments passed into buildLinux (correct place for modDirVersion/src)
              argsOverride = {
                version = ver;
                modDirVersion = rev; # keep it identical to upstream
                src = prev.fetchFromGitLab {
                  owner = "xanmod";
                  repo = "linux";
                  rev = rev;
                  hash = hash;
                };
              };
            }).overrideAttrs
              (old: {
                # Speed rebuilds
                stdenv = final.ccacheStdenv;

                # Provide rustfmt to silence optional rustfmt warnings in kernel build
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.buildPackages.rustfmt ];

                # Keep xanmod config; add desktop/gaming responsiveness
                structuredExtraConfig =
                  (old.structuredExtraConfig or { })
                  // (with prev.lib.kernel; {
                    # Explicitly lock in xanmod defaults you like

                    # Set CPU Schedulers
                    CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkOverride 80 yes;
                    CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = lib.mkOverride 80 no;
                    # Upstream includes these:
                    CPU_IDLE_GOV_HALTPOLL = yes;
                    CPU_IDLE_GOV_LADDER = yes;
                    CPU_IDLE_GOV_TEO = yes;

                    # Modern x86 features for better performance:
                    X86_FRED = yes; # Flexible Return and Event Delivery
                    X86_POSTED_MSI = yes; # Posted MSI support

                    # Preemptive tickless idle kernel
                    NO_HZ = no;
                    NO_HZ_FULL = no;
                    NO_HZ_IDLE = yes;
                    HZ = freeform "1000";
                    HZ_1000 = yes;
                    HZ_250 = no;

                    PREEMPT = lib.mkOverride 80 yes;
                    PREEMPT_DYNAMIC = lib.mkOverride 80 no;
                    PREEMPT_VOLUNTARY = no;
                    PREEMPT_LAZY = no;

                    # RCU for better preemption
                    RCU_EXPERT = yes;
                    RCU_FANOUT = freeform "64";
                    RCU_FANOUT_LEAF = freeform "16";
                    RCU_EXP_KTHREAD = yes;
                    RCU_NOCB_CPU = yes;
                    RCU_DOUBLE_CHECK_CB_TIME = yes;
                    RCU_BOOST = lib.mkOverride 80 yes; # Reduces latency spikes
                    RCU_BOOST_DELAY = freeform "0"; # Quick boost for responsiveness

                    # I/O Schedulers - both available, choose at runtime
                    IOSCHED_BFQ = yes; # Best for desktop/interactive I/O
                    MQ_IOSCHED_DEADLINE = yes; # Good for NVMe
                    MQ_IOSCHED_KYBER = yes; # Low-latency alternative

                    # Memory management
                    TRANSPARENT_HUGEPAGE = yes; # Helps with large allocations (games, VRAM)
                    TRANSPARENT_HUGEPAGE_ALWAYS = no;
                    TRANSPARENT_HUGEPAGE_MADVISE = yes; # App-controlled, safer

                    # High-res timers
                    HIGH_RES_TIMERS = yes;

                    TCP_CONG_BBR = lib.mkOverride 80 yes;
                    DEFAULT_BBR = lib.mkOverride 80 yes;

                    SCHED_AUTOGROUP = lib.mkOverride 80 yes;
                    NET_SCH_FQ = lib.mkOverride 80 yes;
                    DEFAULT_FQ = lib.mkOverride 80 yes;
                  })
                  // extraConfig;
              });
        in
        {
          # Function to build a pinned xanmod
          linux-xanmod-custom = makeXanmodKernel;

          # Convenience: latest xanmod with 1000Hz + ccache
          linux-xanmod-1000hz =
            let
              base = (prev.linuxPackages_xanmod_latest or prev.linuxPackages_xanmod).kernel;
            in
            base.overrideAttrs (old: {
              stdenv = final.ccacheStdenv;
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.buildPackages.rustfmt ];
              # Keep xanmod config; add desktop/gaming responsiveness
              structuredExtraConfig =
                (old.structuredExtraConfig or { })
                // (with prev.lib.kernel; {
                  # Explicitly lock in xanmod defaults you like

                  # Set CPU Schedulers
                  CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkOverride 80 yes;
                  CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = lib.mkOverride 80 no;
                  # Upstream includes these:
                  CPU_IDLE_GOV_HALTPOLL = yes;
                  CPU_IDLE_GOV_LADDER = yes;
                  CPU_IDLE_GOV_TEO = yes;

                  # Modern x86 features for better performance:
                  X86_FRED = yes; # Flexible Return and Event Delivery
                  X86_POSTED_MSI = yes; # Posted MSI support

                  # Preemptive tickless idle kernel
                  NO_HZ = no;
                  NO_HZ_FULL = no;
                  NO_HZ_IDLE = yes;
                  HZ = freeform "1000";
                  HZ_1000 = yes;
                  HZ_250 = no;

                  PREEMPT = lib.mkOverride 80 yes;
                  PREEMPT_DYNAMIC = lib.mkOverride 80 no;
                  PREEMPT_VOLUNTARY = no;
                  PREEMPT_LAZY = no;

                  # RCU for better preemption
                  RCU_EXPERT = yes;
                  RCU_FANOUT = freeform "64";
                  RCU_FANOUT_LEAF = freeform "16";
                  RCU_EXP_KTHREAD = yes;
                  RCU_NOCB_CPU = yes;
                  RCU_DOUBLE_CHECK_CB_TIME = yes;
                  RCU_BOOST = lib.mkOverride 80 yes; # Reduces latency spikes
                  RCU_BOOST_DELAY = freeform "0"; # Quick boost for responsiveness

                  # I/O Schedulers - both available, choose at runtime
                  IOSCHED_BFQ = yes; # Best for desktop/interactive I/O
                  MQ_IOSCHED_DEADLINE = yes; # Good for NVMe
                  MQ_IOSCHED_KYBER = yes; # Low-latency alternative

                  # Memory management
                  TRANSPARENT_HUGEPAGE = yes; # Helps with large allocations (games, VRAM)
                  TRANSPARENT_HUGEPAGE_ALWAYS = no;
                  TRANSPARENT_HUGEPAGE_MADVISE = yes; # App-controlled, safer

                  # High-res timers
                  HIGH_RES_TIMERS = yes;

                  TCP_CONG_BBR = lib.mkOverride 80 yes;
                  DEFAULT_BBR = lib.mkOverride 80 yes;

                  SCHED_AUTOGROUP = lib.mkOverride 80 yes;
                  NET_SCH_FQ = lib.mkOverride 80 yes;
                  DEFAULT_FQ = lib.mkOverride 80 yes;
                })
                // extraConfig;
            });

          linuxPackages_xanmod_1000hz = prev.linuxPackagesFor final.linux-xanmod-1000hz;
        }
    )
  ];

  # Pin to 6.18.0-xanmod1 (replace fakeHash after first build)
  boot.kernelPackages = lib.mkForce (
    pkgs.linuxPackagesFor (
      pkgs.linux-xanmod-custom {
        version = "6.18.0";
        suffix = "xanmod1";
        hash = "sha256-voGRfxlZuejQvalSj/teB8XMvnzE3VG15kCtsNTCFFo=";
      }
    )
  );

  programs.ccache.enable = true;
}
