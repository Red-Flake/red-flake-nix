{ config, lib, pkgs, modulesPath, ... }:

{
    # enable Docker support
    virtualisation.docker.enable = true;

    # enable LXC support
    virtualisation.lxd.enable = true;
    virtualisation.lxc.lxcfs.enable = true;

    # enable Libvirt support
    virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [(pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd];
          };
        };
    };

    # enable virt-manager
    programs.virt-manager.enable = true;

    # enable VirtualBox
    virtualisation.virtualbox.host.enable = true;

    # enable VirtualBox ExtensionPack
    virtualisation.virtualbox.host.enableExtensionPack = true;

}