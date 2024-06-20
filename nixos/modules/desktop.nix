{ config, lib, pkgs, modulesPath, ... }:

{
  # X11 / Wayland settings
   services.xserver.enable = true;
   services.xserver.videoDrivers = [ "intel amdgpu nvidia" ];
   services.displayManager.sddm.enable = true;
   services.displayManager.defaultSession = "plasma";
   services.desktopManager.plasma6.enable = true;
   services.displayManager.sddm.wayland.enable = true;

   # Sound settings
   # Disable actkbd so KDE can handle media keys
   sound.mediaKeys.enable = false;
}
