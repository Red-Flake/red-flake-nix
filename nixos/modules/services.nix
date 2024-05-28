{ config, lib, pkgs, modulesPath, ... }:

{
    services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "yes";
          PasswordAuthentication = true;
        };
      };
    
      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.defaultSession = "plasma";
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.wayland.enable = true;
}