{ pkgs
, lib
, ...
}:

{
  nixpkgs.overlays = lib.mkAfter [
    (
      final: prev:
        let
          # Custom kernel config - applied directly via buildLinux to bypass xanmod's override issue
          customKernelConfig = with prev.lib.kernel; {
            # Set CPU Schedulers
            CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkForce yes;
            CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = lib.mkForce no;
            CPU_IDLE_GOV_LADDER = yes;
            CPU_IDLE_GOV_TEO = yes;
            CPU_IDLE_GOV_MENU = yes;

            # Modern x86 features for better performance
            X86_FRED = yes;
            X86_POSTED_MSI = yes;
            # Require x86-64-v3 ISA baseline (AVX2/BMI/FMA, etc.)
            X86_64_VERSION = lib.mkForce (freeform "3");

            # Timer tick handling: tickless idle
            HZ_PERIODIC = lib.mkForce no;
            NO_HZ_IDLE = lib.mkForce yes;
            NO_HZ_FULL = lib.mkForce no;
            # (NO_HZ / NO_HZ_COMMON: don’t force unless you know the exact symbols in this kernel)

            # 1000Hz tickless idle kernel
            HZ = freeform "1000";
            HZ_1000 = yes;
            HZ_250 = no;
            HZ_100 = no;
            HZ_300 = no;

            # Full preemption (not lazy, not voluntary)
            PREEMPT = lib.mkForce yes;
            PREEMPT_DYNAMIC = lib.mkForce no;
            PREEMPT_VOLUNTARY = lib.mkForce no;
            PREEMPT_LAZY = lib.mkForce no;

            # RCU tuning for low latency
            RCU_EXPERT = yes;
            RCU_FANOUT = freeform "64";
            RCU_FANOUT_LEAF = freeform "16";
            RCU_EXP_KTHREAD = yes;
            #RCU_NOCB_CPU = yes;
            RCU_DOUBLE_CHECK_CB_TIME = yes;
            RCU_BOOST = yes;
            RCU_BOOST_DELAY = freeform "300";

            # I/O Schedulers (use mkForce to override common-config.nix defaults)
            IOSCHED_BFQ = lib.mkForce yes;
            MQ_IOSCHED_DEADLINE = lib.mkForce yes;
            MQ_IOSCHED_KYBER = lib.mkForce yes;

            # Memory management
            TRANSPARENT_HUGEPAGE = yes;
            TRANSPARENT_HUGEPAGE_ALWAYS = no;
            TRANSPARENT_HUGEPAGE_MADVISE = yes;
            # Enable Multi-Gen LRU (MGLRU) - drastically improves responsiveness under memory pressure
            LRU_GEN = yes;
            LRU_GEN_ENABLED = yes;

            # High-res timers
            HIGH_RES_TIMERS = yes;

            # Networking
            TCP_CONG_BBR = yes;
            DEFAULT_BBR = yes;
            NET_SCH_FQ = yes;

            # Scheduler
            SCHED_AUTOGROUP = yes;

            # Disable NUMA balancing: adds overhead on single-socket consumer CPUs; only useful for multi-socket servers
            NUMA_BALANCING = lib.mkForce no;

            # Enable Cluster Scheduling: Optimizes task placement for Hybrid CPUs (Intel Core Ultra/Alder/Raptor Lake)
            # by keeping related tasks within the same E-core cluster (shared L2 cache)
            SCHED_CLUSTER = lib.mkForce yes;

            # Scheduler Extensions (sched_ext)
            # Required for running BPF schedulers like LAVD/Rusty (defined in performance.nix services.scx)
            SCHED_CLASS_EXT = lib.mkForce yes;

            # Gaming & Windows Compatibility
            # Standard XanMod patches (Clear Linux, Futex2, PCIeACS, BBRv3) are already included in the source.
            # We explicitly enable NT Sync for modern Proton performance (WINENTSYNC="1").
            NTSYNC = lib.mkForce module; # Modern driver (Linux 6.10+)
          };

          # Build xanmod kernel from source with our config (bypasses nixpkgs xanmod structuredExtraConfig)
          makeXanmodKernel =
            { version
            , hash
            , suffix ? "xanmod1"
            , extraConfig ? { }
            ,
            }:
            let
              modDirVersion = "${lib.versions.pad 3 version}-${suffix}";
            in
            (prev.buildLinux {
              inherit version modDirVersion;
              pname = "linux-xanmod-custom";

              src = prev.fetchFromGitLab {
                owner = "xanmod";
                repo = "linux";
                rev = modDirVersion;
                inherit hash;
              };

              structuredExtraConfig = customKernelConfig // extraConfig;
            }).overrideAttrs
              (old: {
                stdenv = final.ccacheStdenv;
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.buildPackages.rustfmt ];
              });
        in
        {
          linux-xanmod-custom = makeXanmodKernel;
        }
    )
  ];

  # Pin to 6.18.7-xanmod1 (replace fakeHash after first build)
  boot.kernelPackages = lib.mkForce (
    pkgs.linuxPackagesFor (
      pkgs.linux-xanmod-custom {
        version = "6.18.7";
        suffix = "xanmod1";
        hash = "sha256-kMnJGI0GJ6Cgi5jqrLHRzHI2yE/KEOtBtvgevKnSDO8=";
      }
    )
  );

  programs.ccache.enable = true;
}
