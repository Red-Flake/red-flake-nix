{ config, lib, pkgs, modulesPath, ... }:

{
    # enable Docker support
    virtualisation.docker.enable = true;

    # enable LXC support
    virtualisation.lxd.enable = true;
    virtualisation.lxc.lxcfs.enable = true;
}