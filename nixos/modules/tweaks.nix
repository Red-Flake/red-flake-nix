{ config, lib, pkgs, modulesPath, ... }:

{
  # make /etc/hosts writable on demand
  environment.etc.hosts.mode = "0644";
}
