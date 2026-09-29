# An additional session; Plasma and the existing SDDM default remain enabled.
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  services.upower.enable = true;

  # Desktop-specific routing prevents the common KDE portal fallback from
  # handling Hyprland's screen capture requests.
  xdg.portal.config.hyprland = {
    default = [ "hyprland" "gtk" ];
    "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    "org.freedesktop.impl.portal.Secret" = [ "kwallet" ];
  };
  environment.systemPackages = [ pkgs.kdePackages.qtwayland ];
  home-manager.users.pascal.imports = [
    ../../../home-manager/pascal/modules/hyprland
  ];
}
