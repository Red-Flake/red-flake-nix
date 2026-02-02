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
            # Set localversion
            LOCALVERSION = freeform "-redflake";

            # Enable "performance" optimization (matches upstream)
            CC_OPTIMIZE_FOR_PERFORMANCE = lib.mkForce yes;

            # Enable ThinLTO
            # Disable for now......
            #LTO_NONE = lib.mkForce no;
            #LTO = lib.mkForce yes;
            #LTO_CLANG = lib.mkForce yes;
            #ARCH_SUPPORTS_LTO_CLANG = lib.mkForce yes;
            #ARCH_SUPPORTS_LTO_CLANG_THIN = lib.mkForce yes;
            #HAS_LTO_CLANG = lib.mkForce yes;
            #LTO_CLANG_THIN = lib.mkForce yes;
            #LTO_CLANG_FULL = lib.mkForce no;

            # Set CPU Schedulers
            CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkForce yes;
            CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = lib.mkForce no;
            CPU_IDLE_GOV_LADDER = lib.mkForce yes;
            CPU_IDLE_GOV_TEO = lib.mkForce yes;
            CPU_IDLE_GOV_MENU = lib.mkForce yes;

            # Modern x86 features for better performance
            # NOTE: X86_NATIVE_CPU doesn't select a CPU family in 6.18.x, so
            # X86_L1_CACHE_SHIFT has no default and the build fails without it.
            # 6 => 64-byte line size (typical for modern x86-64 CPUs).
            X86_NATIVE_CPU = lib.mkForce yes;
            X86_L1_CACHE_SHIFT = freeform "6";
            X86_FRED = lib.mkForce yes;
            X86_POSTED_MSI = lib.mkForce yes;

            # Timer tick handling: tickless idle
            HZ_PERIODIC = lib.mkForce no;
            NO_HZ_IDLE = lib.mkForce yes;
            NO_HZ_FULL = lib.mkForce no;
            # (NO_HZ / NO_HZ_COMMON: don’t force unless you know the exact symbols in this kernel)

            # 1000Hz tickless idle kernel
            HZ = freeform "1000";
            HZ_1000 = lib.mkForce yes;
            HZ_250 = lib.mkForce no;
            HZ_100 = lib.mkForce no;
            HZ_300 = lib.mkForce no;

            # Full preemption (not lazy, not voluntary)
            PREEMPT = lib.mkForce yes;
            PREEMPT_DYNAMIC = lib.mkForce no;
            PREEMPT_VOLUNTARY = lib.mkForce no;
            PREEMPT_LAZY = lib.mkForce no;

            # Do not treat warnings as errors (GCC 15 triggers new warnings in libbpf).
            WERROR = lib.mkForce no;

            # RCU tuning for low latency
            RCU_EXPERT = lib.mkForce yes;
            RCU_FANOUT = freeform "64";
            RCU_FANOUT_LEAF = freeform "16";
            RCU_EXP_KTHREAD = lib.mkForce yes;
            #RCU_NOCB_CPU = yes;
            RCU_DOUBLE_CHECK_CB_TIME = lib.mkForce yes;
            RCU_BOOST = lib.mkForce yes;
            RCU_BOOST_DELAY = freeform "300";

            # I/O Schedulers (use mkForce to override common-config.nix defaults)
            IOSCHED_BFQ = lib.mkForce yes;
            MQ_IOSCHED_DEADLINE = lib.mkForce yes;
            MQ_IOSCHED_KYBER = lib.mkForce yes;

            # Memory management
            TRANSPARENT_HUGEPAGE = lib.mkForce yes;
            TRANSPARENT_HUGEPAGE_ALWAYS = lib.mkForce no;
            TRANSPARENT_HUGEPAGE_MADVISE = lib.mkForce yes;
            # Enable Multi-Gen LRU (MGLRU) - drastically improves responsiveness under memory pressure
            LRU_GEN = lib.mkForce yes;
            LRU_GEN_ENABLED = lib.mkForce yes;

            # High-res timers
            HIGH_RES_TIMERS = lib.mkForce yes;

            # Networking
            TCP_CONG_BBR = lib.mkForce yes;
            DEFAULT_BBR = lib.mkForce yes;
            NET_SCH_FQ = lib.mkForce yes;
            # (BBRv3 + Cake QoS)
            NET_SCH_CAKE = lib.mkForce yes; # Low-latency gaming neteq

            # Scheduler
            SCHED_AUTOGROUP = lib.mkForce yes;

            # Storage (NVMe + ZFS)
            NVME_MULTIPATH = lib.mkForce yes; # RAID-0 NVMe perf
            BLK_CGROUP_IOCOST = lib.mkForce yes; # IO fairness (ZFS)

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

            # Low-latency gaming/desktop (6.18+ Lunar Lake)
            RSEQ = lib.mkForce yes; # User-space rseq (futex2/Proton)
            FUSE_FS = lib.mkForce yes; # Bottleneck-free Steam Proton FS
            ZRAM = lib.mkForce module; # Compressed swap (memory pressure)
            ZSMALLOC = lib.mkForce yes; # Required for zram/MGLRU

            WIREGUARD = lib.mkForce module; # Faster VPN (Proton/WireGuard)
            SCHED_CORE = lib.mkForce yes; # Core scheduling (P/E-core affinity)
          };

          xanmodVersion = "6.18.8";
          xanmodSuffix = "xanmod1";
          localVersion = "-redflake";
          xanmodModDirVersion = "${xanmodVersion}${localVersion}-${xanmodSuffix}";
          # Fetch hash with:
          # nix store prefetch-file --hash-type sha256 --unpack "https://gitlab.com/xanmod/linux/-/archive/6.18.8-xanmod1/linux-6.18.8-xanmod1.tar.gz"
          xanmodHash = "sha256-BagAixl3Eo9vX6F/vpQv8OCw5vm8l7JtZBqvE0m5gAs=";

          xanmodBase = prev.linux_xanmod_latest;

          linux-xanmod-custom =
            (xanmodBase.override {
              inherit (pkgs.llvmPackages_latest) stdenv;
              argsOverride = {
                version = xanmodVersion;
                suffix = xanmodSuffix;

                # Make the running kernel version unmistakable in uname -r.
                localVersion = "-redflake";
                modDirVersion = xanmodModDirVersion;

                # Force exact source; otherwise linux_xanmod_latest may still fetch an older tarball.
                src = final.fetchFromGitLab {
                  owner = "xanmod";
                  repo = "linux";
                  rev = xanmodModDirVersion;
                  hash = xanmodHash;
                };
                hash = xanmodHash;
                kernelPatches = xanmodBase.kernelPatches ++ [
                  {
                    name = "x86-l1-cache-shift-x86_64";
                    patch = ./patches/x86-l1-cache-shift-x86_64.patch;
                  }
                  {
                    name = "libbpf-no-werror";
                    patch = ./patches/libbpf-no-werror.patch;
                  }
                ];
                structuredExtraConfig = xanmodBase.structuredExtraConfig // customKernelConfig;
              };
            }).overrideAttrs
              (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                  final.buildPackages.rustfmt
                ];

                # Optional: only affects host tools much more than the kernel itself
                NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -march=native -mtune=native -O3 -pipe";

                # Point kbuild at unwrapped toolchain (no cc-wrapper flags like -nostdlibinc)
                makeFlags = (old.makeFlags or [ ]) ++ [
                  # hardcode "-j24" for 24 cpu cores
                  "-j24"

                  # host tool warning suppression (if needed)
                  "HOSTCFLAGS=-Wno-unused-command-line-argument"

                  # O3 for kernel compilation units
                  "KCFLAGS=-march=native -mtune=native -O3 -pipe"
                ];
              });
        in
        {
          inherit linux-xanmod-custom;
        }
    )
  ];

  # Pin to 6.18.8-redflake-xanmod1 (uname -r includes redflake)
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor pkgs.linux-xanmod-custom);
}
