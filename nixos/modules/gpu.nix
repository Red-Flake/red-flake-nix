{ config, lib, pkgsx86_64_v3, modulesPath, ... }:

{
  ## Intel + AMD
  # Load libva driver for accelerated video
  nixpkgs.config.packageOverrides = pkgsx86_64_v3: {
    intel-vaapi-driver = pkgsx86_64_v3.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgsx86_64_v3; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
      rocmPackages.clr.icd
    ];
    extraPackages32 = with pkgsx86_64_v3.pkgsi686Linux; [ intel-vaapi-driver ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  
}
