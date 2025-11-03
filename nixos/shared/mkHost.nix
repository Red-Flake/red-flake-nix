# Function to create standardized NixOS host configurations  
{ config, lib, pkgs, chaoticPkgs, inputs, isKVM, ... }:
let
  profiles = import ./profiles.nix { inherit config lib pkgs chaoticPkgs inputs isKVM; };
  localeProfiles = import ./locale-profiles.nix { inherit lib; };
in
{
  # Create a host configuration from a profile
  mkHost = profileName: hostConfig:
    let
      profile = profiles.${profileName};
      
      # Get locale configuration (default to german-en if not specified)
      localeConfig = if hostConfig ? "localeProfile"
                    then localeProfiles.getLocaleConfig hostConfig.localeProfile "german-en"
                    else if hostConfig ? "customLocale" 
                    then hostConfig.customLocale
                    else localeProfiles.profiles.german-en;
    in
    {
      imports = profile.imports ++ [
        hostConfig.hardwareConfig  # Host-specific hardware.nix
      ] ++ (hostConfig.extraModules or []);

      # Set hostname and derive hostId
      networking.hostName = hostConfig.hostname;
      networking.hostId = if hostConfig ? "hostId" then hostConfig.hostId 
                         else builtins.substring 0 8 (builtins.hashString "md5" hostConfig.hostname);
      
      # Merge any additional configuration
    } // localeConfig // (hostConfig.extraConfig or {}) // (profile.extraConfig or {});
}