{ lib, ... }:
{

  custom = {
    # disable ZFS encryption
    zfs.encryption = lib.mkForce false;

    kernel.cachyos.mArch = "GENERIC_V3";
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
  };

  hardware = {
    # enable firmware with a license allowing redistribution
    enableRedistributableFirmware = lib.mkForce true;

    # enable all firmware regardless of license
    enableAllFirmware = lib.mkForce true;
  };

}
