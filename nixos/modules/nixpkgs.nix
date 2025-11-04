{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  nixpkgs = let
    sharedOverlays = import ../shared/overlays.nix { inherit inputs; };
  in {

    # Set host platform
    hostPlatform = lib.mkDefault "x86_64-linux";

    # Import all overlays from shared configuration
    overlays = sharedOverlays.allOverlays
      ++ lib.optionals config.custom.IntelComputeRuntimeLegacy.enable sharedOverlays.intelLegacyOverlay
      ++ lib.optionals config.hardware.tuxedo-drivers.enable sharedOverlays.tuxedoDriversOverlay;
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;

      # Allow legacy packages
      permittedInsecurePackages = [
        "openssl-1.1.1w"
        "python-2.7.18.8"
      ];
    };
  };
}
