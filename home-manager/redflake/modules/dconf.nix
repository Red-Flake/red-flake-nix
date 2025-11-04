{
  config,
  lib,
  pkgs,
  ...
}:
{
  # dconf user settings
  dconf = {
    enable = true;
    settings = {

      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };

    };
  };
}
