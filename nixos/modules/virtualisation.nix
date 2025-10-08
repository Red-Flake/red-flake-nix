{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # enable Docker support
  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--iptables=false --ip6tables=false";

  # enable Podman support
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = false;
  };

  # set OCI container backend to podman
  virtualisation.oci-containers = {
    backend = "podman";
  };

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces =
    let
      matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
    in
    {
      "${matchAll}".allowedUDPPorts = [ 53 ];
    };

  # enable LXC support
  #virtualisation.lxd.enable = true;    ## LXD has been removed from NixOS due to lack of Nixpkgs maintenance.
  #virtualisation.lxc.lxcfs.enable = true;

  # enable Libvirt support
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;

      ## The 'virtualisation.libvirtd.qemu.ovmf' submodule has been removed. All OVMF images distributed with QEMU are now available by default.
      /*
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      */

    };
  };

  # enable virt-manager
  programs.virt-manager.enable = true;

  # enable VirtualBox
  #virtualisation.virtualbox.host.enable = true;

  # enable VirtualBox ExtensionPack
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  virtualisation.containers.storage.settings = lib.mkIf (config.fileSystems."/".fsType == "zfs") {
    storage = {
      driver = "zfs";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };
  };

}
