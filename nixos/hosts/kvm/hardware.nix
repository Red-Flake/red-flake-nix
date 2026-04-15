{ lib, ... }:
{

  custom = {
    # disable ZFS encryption
    zfs.encryption = lib.mkForce false;

    # set display resolution to 1080p
    display.resolution = "1080p";
  };

  boot = {
    initrd.availableKernelModules = [
      "zfs"
      "ahci"
      "xhci_pci"
      "virtio_pci"
      "virtio_blk"
      "virtio_net" # network
      "virtio_balloon" # memory ballooning
      "virtio_console" # serial/console
      "virtio_scsi" # if using scsi controller
      "sr_mod"
      "virtio_rng" # faster entropy from the host's /dev/random
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    kernelParams = [
      "quiet"
      "splash"
      "mitigations=off"
      "libahci.ignore_sss=1"
      "sysrq_always_enabled=1"
      "split_lock_detect=off"
      "audit=0"
      "net.ifnames=0"
      "biosdevname=0"
    ];
  };

  # enable spice-autorandr service that will automatically resize display to match SPICE client window size.
  services.spice-autorandr.enable = true;

  # enable Spice guest vdagent daemon
  services.spice-vdagentd.enable = true;

  # enable QEMU guest agent for better integration with the host (e.g. automatic shutdown, improved clipboard sharing, etc.)
  services.qemuGuest.enable = true;
}
