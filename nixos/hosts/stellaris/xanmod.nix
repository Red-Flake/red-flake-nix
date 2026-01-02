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
            CPU_IDLE_GOV_HALTPOLL = yes;
            CPU_IDLE_GOV_LADDER = yes;
            CPU_IDLE_GOV_TEO = yes;

            # Modern x86 features for better performance
            X86_FRED = yes;
            X86_POSTED_MSI = yes;

            # 1000Hz tickless idle kernel
            NO_HZ = no;
            NO_HZ_FULL = lib.mkForce no;
            NO_HZ_IDLE = yes;
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
            RCU_NOCB_CPU = yes;
            RCU_DOUBLE_CHECK_CB_TIME = yes;
            RCU_BOOST = yes;
            RCU_BOOST_DELAY = freeform "0";

            # I/O Schedulers (use mkForce to override common-config.nix defaults)
            IOSCHED_BFQ = lib.mkForce yes;
            MQ_IOSCHED_DEADLINE = lib.mkForce yes;
            MQ_IOSCHED_KYBER = lib.mkForce yes;

            # Memory management
            TRANSPARENT_HUGEPAGE = yes;
            TRANSPARENT_HUGEPAGE_ALWAYS = no;
            TRANSPARENT_HUGEPAGE_MADVISE = yes;

            # High-res timers
            HIGH_RES_TIMERS = yes;

            # Networking
            TCP_CONG_BBR = yes;
            DEFAULT_BBR = yes;
            NET_SCH_FQ = yes;

            # Scheduler
            SCHED_AUTOGROUP = yes;
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
            }).overrideAttrs (old: {
              stdenv = final.ccacheStdenv;
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.buildPackages.rustfmt ];
            });
        in
        {
          linux-xanmod-custom = makeXanmodKernel;
        }
    )
  ];

  # Pin to 6.18.2-xanmod1 (replace fakeHash after first build)
  boot.kernelPackages = lib.mkForce (
    pkgs.linuxPackagesFor (
      pkgs.linux-xanmod-custom {
        version = "6.18.2";
        suffix = "xanmod1";
        hash = "sha256-LSzoUpQiqVAeboKKyRzKyiYpuUbueJvHTtN5mm8EHL8=";
      }
    )
  );

  programs.ccache.enable = true;
}
