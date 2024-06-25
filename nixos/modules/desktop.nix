{ config, lib, pkgs, modulesPath, ... }:

{
  # X11 / Wayland settings
  services.xserver = {
     enable = true;
     videoDrivers = [ "intel amdgpu nvidia" ];
  };
   
  # Display-Manager settings
  services.displayManager = {
    # Enable SDDM
    sddm.enable = true;

    # Set default session to KDE Plasma
    defaultSession = "plasma";

    # Run SDDM under Wayland
    sddm.wayland.enable = true;
  };

  # Desktop-Manager settings
  services.desktopManager = {
    # Enable Plasma 6
    plasma6.enable = true;
  };

  # Sound settings
  # Disable actkbd so KDE can handle media keys
  sound.mediaKeys.enable = false;
  
  # enable dconf
  # Fix GTK themes not applied in Wayland
  programs.dconf.enable = true;
  
  # enable xdg desktop portal
  xdg.portal = {
   enable = true;
   extraPortals = with pkgs; [
     kdePackages.xdg-desktop-portal-kde
     xdg-desktop-portal-gtk
   ];
  };

  # Electron and Chromium
  ## As of NixOS 22.05 ("Quokka"), you can enable Ozone Wayland support in Chromium and Electron based applications by setting the environment variable NIXOS_OZONE_WL=1. For example, in a configuration.nix: 
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Firefox
  ## Enable wayland for firefox
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

  # Run GTK applications under wayland
  environment.sessionVariables.GDK_BACKEND = "wayland";
  
}
