# Function to create standardized NixOS host configurations
{ config
, lib
, pkgs
, chaoticPkgs
, inputs
, isKVM
, ...
}:
let
  profiles = import ./profiles.nix {
    inherit
      config
      lib
      pkgs
      chaoticPkgs
      inputs
      isKVM
      ;
  };
  localeProfiles = import ./locale-profiles.nix { inherit lib; };
in
{
  # Create a host configuration from a profile
  mkHost =
    profileName: hostConfigPath: hostParams:
    let
      profile = profiles.${profileName};

      # Get locale configuration (default to german-en if not specified)
      localeConfig =
        if hostParams ? "localeProfile" then
          localeProfiles.getLocaleConfig hostParams.localeProfile "german-en"
        else if hostParams ? "customLocale" then
          hostParams.customLocale
        else
          localeProfiles.profiles.german-en;
    in
    {
      imports =
        profile.imports
        ++ [
          hostConfigPath # Host-specific configuration (default.nix)
        ]
        ++ (hostParams.extraModules or [ ]);

      # Set hostname and derive hostId
      networking.hostName = hostParams.hostname;
      networking.hostId =
        if hostParams ? "hostId" then
          hostParams.hostId
        else
          builtins.substring 0 8 (builtins.hashString "md5" hostParams.hostname);

      # Merge any additional configuration
    }
    // localeConfig
    // (hostParams.extraConfig or { })
    // (profile.extraConfig or { });
}
