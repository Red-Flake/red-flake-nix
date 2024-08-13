{ inputs, system }:

let
  lib = inputs.nixpkgs.lib;
  pkgs = inputs.nixpkgs.lib.mkNixpkgs {
    inherit system;
  };
in
{
  mkHost =
    { host
    , user
    , homeModules ? [ ]
    }:
    pkgs.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs user;
      };

      modules = [
        # host configuration
        (../nixos/hosts + "/${host}")

        # home manager
        inputs.homeManager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."${user}" = {
              imports = homeModules;
            };
          };
        }
      ];
    };
}