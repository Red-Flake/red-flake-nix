_:

{
  # Enforce a few runtime knobs that are *not* sysctls (sysfs), so they actually
  # apply consistently at boot.
  #
  # Note: MGLRU is controlled via /sys/kernel/mm/lru_gen/* on this kernel; the
  # vm.lru_gen_enabled sysctl does not exist here.
  systemd.tmpfiles.rules = [
    # Transparent Huge Pages: prefer explicit madvise() (low-latency default).
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise"
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - madvise"

    # Multi-Gen LRU: keep it enabled (0x0007 == enabled with the common feature set).
    "w /sys/kernel/mm/lru_gen/enabled - - - - 0x0007"
  ];

  # Increase systemd limits
  systemd.settings.Manager = {
    DefaultLimitNOFILE = 1048576;
    DefaultLimitNPROC = 1048576;
  };

  # Set user limits
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "1048576";
    }
  ];

  boot.kernel.sysctl = {
    # Set sysctl parameters

    # Set swappiness to only swap if you really have to
    # The sysctl swappiness parameter determines the kernel's preference for pushing anonymous pages or page cache to disk in memory-starved situations.
    # A low value causes the kernel to prefer freeing up open files (page cache), a high value causes the kernel to try to use swap space,
    # and a value of 100 means IO cost is assumed to be equal.
    # OPTIMIZATION: With ZRAM enabled, we want a high swappiness (100).
    # Rationale: It is much faster to compress idle "dirty" memory (ZRAM) than it is to discard active file cache
    # (which would cause stutter when those files are needed again).
    "vm.swappiness" = 100;

    # Adjust cache pressure
    # The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
    # Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
    "vm.vfs_cache_pressure" = 10;

    # Use byte-based limits for 96 GB RAM (avoids huge % thresholds)
    # Background flusher starts at ~1.5 GiB dirty (smooth, low-burst on ZFS/NVMe).
    # Foreground throttle at ~4 GiB (prevents stalls without aggressive writes).
    # Disable ratios when using bytes.
    "vm.dirty_background_bytes" = 1610612736; # 1.5 GiB
    "vm.dirty_bytes" = 4294967296; # 4 GiB
    "vm.dirty_background_ratio" = 0;
    "vm.dirty_ratio" = 0;

    # More frequent writeback (2.5s vs 10s) eliminates bursty flushes/stutters.
    "vm.dirty_writeback_centisecs" = 250; # 2.5 seconds

    # Reasonable expire time (default-ish, pages sit dirty up to 30s before forced).
    "vm.dirty_expire_centisecs" = 3000;

    # Enable Multi-Gen LRU for better reclaim behavior under mixed workloads.
    # NOTE: this kernel exposes MGLRU controls via /sys/kernel/mm/lru_gen/* (sysfs),
    # not via a vm.lru_gen_enabled sysctl. See systemd.tmpfiles.rules above.

    # page-cluster controls the number of pages up to which consecutive pages are read in from swap in a single attempt.
    # This is the swap counterpart to page cache readahead. The mentioned consecutivity is not in terms of virtual/physical addresses,
    # but consecutive on swap space - that means they were swapped out together. (Default is 3)
    # increase this value to 1 or 2 if you are using physical swap (1 if ssd, 2 if hdd)
    "vm.page-cluster" = 0; # Set to 0 for SSD

    # Allow unprivileged users to bind ports below 1024
    "net.ipv4.ip_unprivileged_port_start" = 0;

    # Increase max_user_watches
    # Defines the maximum number of file watches that can be registered.
    "fs.inotify.max_user_watches" = 1048576;

    # Set size of file handles and inode cache
    # Sets the maximum number of file descriptors that can be allocated.
    "fs.file-max" = 4194304;

    # Defines the maximum number of asynchronous I/O requests that can be in progress at a given time.
    "fs.aio-max-nr" = 1000000; # 1 million

    # Increase the sched_rt_runtime_us to mitigate issues:
    # sched: RT throttling activated
    # Defines the time (in microseconds) that real-time tasks can run without being throttled.
    "kernel.sched_rt_runtime_us" = 950000;

    # Improve interactive responsiveness by grouping tasks per TTY/session.
    "kernel.sched_autogroup_enabled" = 1;

    # Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
    "kernel.unprivileged_userns_clone" = 1;

    # Hide any kernel messages from the console
    # Adjust the console log level to suppress messages.
    "kernel.printk" = "3 3 3 3";

    # Hide kernel pointers even more
    # If you sometimes do kernel debugging / ebpf dev, leave it at 1.
    "kernel.kptr_restrict" = 2;

    # Disable Kexec, which allows replacing the current running kernel.
    # Enhances security by preventing kernel replacement.
    "kernel.kexec_load_disabled" = 1;

    # Increase the maximum connections
    # The upper limit on how many connections the kernel will accept (default 4096 since kernel version 5.6):
    "net.core.somaxconn" = 8192;

    # Enable SysRQ for rebooting the machine properly if it freezes.
    # Useful for emergency recovery.
    "kernel.sysrq" = 1;

    # Allows a large number of processes and threads to be managed
    # Sets the maximum number of process IDs that can be allocated.
    "kernel.pid_max" = 262144;

    # Help prevent packet loss during high traffic periods.
    # Defines the maximum number of packets that can be queued on the network device input queue.
    "net.core.netdev_max_backlog" = 65536;

    # Default socket receive buffer size, improve network performance & applications that use sockets. Adjusted for 8GB RAM.
    "net.core.rmem_default" = 1048576; # 1 MB

    # Maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 8GB RAM.
    "net.core.rmem_max" = 134217728; # 128 MB

    # Default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 8GB RAM.
    "net.core.wmem_default" = 1048576; # 1 MB

    # Maximum socket send buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 8GB RAM.
    "net.core.wmem_max" = 134217728; # 128 MB

    # Reduce the chances of fragmentation. Adjusted for SSD.
    # NOTE: correct key name is *_thresh (not *_threshold).
    "net.ipv4.ipfrag_high_thresh" = 5242880; # 5 MB

    # Enable TCP window scaling
    # Allows the TCP window size to grow beyond its default maximum value.
    "net.ipv4.tcp_window_scaling" = 1;

    # TCP read memory settings: minimum, default, and maximum buffer size
    # These settings define the memory reserved for TCP read operations.
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";

    # TCP write memory settings: minimum, default, and maximum buffer size
    # These settings define the memory reserved for TCP write operations.
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";

    # Use the BBR congestion control algorithm for improved network performance
    # BBR optimizes for low latency and high throughput.
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Use Fair Queueing (FQ) as the default queuing discipline
    # For this host we intentionally default to CAKE (compiled in via the custom XanMod config)
    # to keep queueing latency down system-wide.
    "net.core.default_qdisc" = "cake";

    # TIME-WAIT assassination protection
    "net.ipv4.tcp_rfc1337" = 1;

    # Shorter FIN timeout (laptop / workstation)
    "net.ipv4.tcp_fin_timeout" = 30;

    # Wider ephemeral port range
    # For a box that might run lots of concurrent outbound connections a wider range gives more breathing room.
    "net.ipv4.ip_local_port_range" = "15000 65535";

    # Log weird source addresses
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;

    # TCP Fast Open (already have BBR/FQ, add this)
    "net.ipv4.tcp_fastopen" = 3;

    # MTU probing for better network performance
    "net.ipv4.tcp_mtu_probing" = 1;

    # Disable watchdogs for lower latency (add to boot.kernel.sysctl section)
    "kernel.nmi_watchdog" = 0;
    "kernel.watchdog" = 0;

    # Leave timer migration at the default (helps keep timers on housekeeping CPUs and avoids
    # concentrating timer work on a subset of cores).
    #"kernel.timer_migration" = 1;

    # Increase max memory map areas - required by many games and Electron apps
    # Steam Deck uses this value; fixes crashes in some games
    "vm.max_map_count" = 1048576;

    # Disable proactive memory compaction to avoid latency spikes
    "vm.compaction_proactiveness" = 0;
  };
}
