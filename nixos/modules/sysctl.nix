{ ...
}:

{
  boot.kernel.sysctl = {
    # Set sysctl parameters

    # Set swappiness to only swap if you really have to
    # The sysctl swappiness parameter determines the kernel's preference for pushing anonymous pages or page cache to disk in memory-starved situations.
    # A low value causes the kernel to prefer freeing up open files (page cache), a high value causes the kernel to try to use swap space,
    # and a value of 100 means IO cost is assumed to be equal.
    "vm.swappiness" = 1;

    # Adjust cache pressure
    # The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
    # Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
    "vm.vfs_cache_pressure" = 30;

    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which a process which is generating disk writes will itself start
    # writing out dirty data.
    "vm.dirty_bytes" = 1073741824; # 1 GB

    # Optimize storage related settings
    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which the background kernel flusher threads will start writing out
    # dirty data.
    "vm.dirty_background_bytes" = 268435456; # 256M

    # The kernel flusher threads will periodically wake up and write old data out to disk.
    # This tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
    "vm.dirty_writeback_centisecs" = 1000; # 10 seconds

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

    # Increase writeback interval for xfs
    # Defines the interval (in centiseconds) at which the XFS kernel threads flush data to disk.
    "fs.xfs.xfssyncd_centisecs" = 10000; # 100 seconds

    # Defines the maximum number of asynchronous I/O requests that can be in progress at a given time.
    "fs.aio-max-nr" = 1000000; # 1 million

    # Disable core dumps
    # Redirect core dumps to /dev/null to disable them.
    "kernel.core_pattern" = "/dev/null";

    # Increase the sched_rt_runtime_us to mitigate issues:
    # sched: RT throttling activated
    # Defines the time (in microseconds) that real-time tasks can run without being throttled.
    "kernel.sched_rt_runtime_us" = 980000;

    # Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
    "kernel.unprivileged_userns_clone" = 1;

    # Hide any kernel messages from the console
    # Adjust the console log level to suppress messages.
    "kernel.printk" = "3 3 3 3";

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
    "net.core.rmem_max" = 67108864; # 64 MB

    # Default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 8GB RAM.
    "net.core.wmem_default" = 1048576; # 1 MB

    # Maximum socket send buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 8GB RAM.
    "net.core.wmem_max" = 67108864; # 64 MB

    # Reduce the chances of fragmentation. Adjusted for SSD.
    "net.ipv4.ipfrag_high_threshold" = 5242880; # 5 MB

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
    # FQ helps to reduce latency and improve overall network performance.
    "net.core.default_qdisc" = "fq";
  };
}
