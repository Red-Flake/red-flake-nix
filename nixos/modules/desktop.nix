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

   # enable dconf
   #programs.dconf.enable = true;

   # enable xdg desktop portal
   #xdg.portal = {
   # enable = true;
   # wlr.enable = true;
    # gtk portal needed to make gtk apps happy
   # extraPortals = [ 
   #   pkgs.xdg-desktop-portal-kde
   #   pkgs.xdg-desktop-portal-gtk
   # ];
  #};
  
}
