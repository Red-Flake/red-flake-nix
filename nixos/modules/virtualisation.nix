{ config, lib, pkgs, modulesPath, ... }:

{
    virtualisation.docker.enable = true;
    virtualisation.lxd.enable = true;
    virtualisation.lxc.lxcfs.enable = true;
}