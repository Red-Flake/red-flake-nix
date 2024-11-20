{ config, lib, pkgs, modulesPath, ... }:

{
  ## Intel GPU config for Thinkpad T580

  # Set initramfs kernel modules
  # Enable Intel video driver via early KMS
  boot.initrd.kernelModules = [
      "i915"
  ];

  boot.kernelParams = [
    "i915.enable_guc=2"
    "i915.enable_fbc=1"
    "i915.enable_psr=2"
  ];

  # X11 / Wayland settings
  services.xserver = {
     enable = true;
     videoDrivers = [ "intel" ];
  };

  # Load libva driver for accelerated video
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  # OpenGL settings
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      #intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      #libvdpau-va-gl
      intel-compute-runtime
      #intel-ocl
      #ocl-icd
      #intel-ocl
      #vpl-gpu-rt
    ];
    #extraPackages32 = with pkgs.pkgsi686Linux; [ intel-vaapi-driver ];
  };

  hardware.intelgpu.vaapiDriver = "intel-media-driver";

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  
  environment.variables = {
    #VDPAU_DRIVER = "va_gl";
    OPENCL_VENDOR_PATH = "/run/opengl-driver/etc/OpenCL/vendors";
  };
  
}