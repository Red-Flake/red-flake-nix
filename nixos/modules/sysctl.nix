{ config, lib, pkgs, modulesPath, ... }:

{
    # Set sysctl parameters

    # Set swappiness to only swap if you really have to
    # The sysctl swappiness parameter determines the kernel's preference for pushing anonymous pages or page cache to disk in memory-starved situations.
    # A low value causes the kernel to prefer freeing up open files (page cache), a high value causes the kernel to try to use swap space,
    # and a value of 100 means IO cost is assumed to be equal.
    boot.kernel.sysctl."vm.swappiness" = 1;

    # Adjust cache pressure
    # The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache). 
    # Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
    boot.kernel.sysctl."vm.vfs_cache_pressure" = 50;

    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which a process which is generating disk writes will itself start
    # writing out dirty data.
    boot.kernel.sysctl."vm.dirty_bytes" = 268435456;

    # Optimize storage related settings
    # Contains, as a bytes of total available memory that contains free pages and reclaimable
    # pages, the number of pages at which the background kernel flusher threads will start writing out
    # dirty data.
    boot.kernel.sysctl."vm.dirty_background_ratio" = 5;
    boot.kernel.sysctl."vm.dirty_ratio" = 10;

    # The kernel flusher threads will periodically wake up and write old data out to disk.  This
    # tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
    boot.kernel.sysctl."vm.dirty_writeback_centisecs" = 1500;

    # page-cluster controls the number of pages up to which consecutive pages are read in from swap in a single attempt. 
    # This is the swap counterpart to page cache readahead. The mentioned consecutivity is not in terms of virtual/physical addresses, 
    # but consecutive on swap space - that means they were swapped out together. (Default is 3)
    # increase this value to 1 or 2 if you are using physical swap (1 if ssd, 2 if hdd)
    boot.kernel.sysctl."vm.page-cluster" = 0;

    # Allow unprivileged users to bind ports below 1024
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

    # Increase max_user_watches
    boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

    # Set size of file handles and inode cache
    boot.kernel.sysctl."fs.file-max" = 2097152;

    # Increase writeback interval  for xfs
    boot.kernel.sysctl."fs.xfs.xfssyncd_centisecs" = 10000;

    # Disable core dumps
    boot.kernel.sysctl."kernel.core_pattern" = "/dev/null";

    # Increase the sched_rt_runtime_us to mitigate issues:
    # sched: RT throttling activated
    boot.kernel.sysctl."kernel.sched_rt_runtime_us" = 980000;

    # This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
    # Disable NMI watchdog
    boot.kernel.sysctl."kernel.nmi_watchdog" = 0;

    # Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

    # Hide any kernel messages from the console
    boot.kernel.sysctl."kernel.printk" = "3 3 3 3";

    # Disable Kexec, which allows replacing the current running kernel. 
    boot.kernel.sysctl."kernel.kexec_load_disabled" = 1;

    # Increase the maximum connections
    # The upper limit on how many connections the kernel will accept (default 4096 since kernel version 5.6):
    boot.kernel.sysctl."net.core.somaxconn" = 8192;

}
