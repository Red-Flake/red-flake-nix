{ config, lib, pkgs, modulesPath, ... }:

{
  ## Intel GPU config for Thinkpad T580

  # Set initramfs kernel modules
  # Enable Intel video driver via early KMS
  boot.initrd.kernelModules = [
      "i915"
  ];

  # Load libva driver for accelerated video
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  # OpenGL settings
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-vaapi-driver ];
  };

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  
  environment.variables = {
    VDPAU_DRIVER = "va_gl";
  };
  
}
