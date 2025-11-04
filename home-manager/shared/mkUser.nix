# Function to create standardized home-manager configurations
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  profiles = import ./profiles.nix { inherit inputs pkgs lib; };
  packages = import ./packages.nix { inherit pkgs; };
in
{
  # Create a user configuration from a profile
  mkUser =
    profileName: extraConfig:
    let
      profile = profiles.${profileName};
    in
    {
      imports = profile.modules ++ (extraConfig.extraModules or [ ]);

      # Pass git config to modules that need it (if it exists)
      _module.args.gitConfig = profile.git or null;

      home = {
        packages = profile.packages ++ (extraConfig.extraPackages or [ ]);
        sessionVariables = profile.sessionVariables // (extraConfig.extraSessionVariables or { });
      }
      // (extraConfig.homeConfig or { });

      # Enable xsession for desktop users
      xsession.enable = lib.mkDefault (builtins.elem "desktop" (extraConfig.tags or [ ]));

      # Common overlays
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
      ]
      ++ (extraConfig.extraOverlays or [ ]);
    }
    // (extraConfig.extraConfig or { });
}
