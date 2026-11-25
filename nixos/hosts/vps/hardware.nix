{ lib, ... }:
{

  custom = {
    # disable ZFS encryption
    zfs.encryption = lib.mkForce false;

    # VPS typically doesn't have NVMe
    storage.hasNVMe = false;
  };

  boot = {
    initrd.availableKernelModules = [
      "zfs"
      "ahci"
      "xhci_pci"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
      "kvm"
      "kvm_intel"
      "kvm_amd"
      "vhost_net"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    kernelParams = [
      "quiet"
      "mitigations=off"
      "libahci.ignore_sss=1"
      "sysrq_always_enabled=1"
      "split_lock_detect=off"
      "audit=0"
      "net.ifnames=0"
    ];
  };

}
