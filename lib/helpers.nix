inputs:

let
  lib = inputs.nixpkgs.lib;
in {

  mkHost =
    { host
    , user
    , system ? "x86_64-linux"
    , homeModules ? [ ]
    , nixpkgs ? inputs.unstable
    }:
    let pkgs = mkNixpkgs { inherit nixpkgs system; };
    in
    nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit pkgs inputs system nixpkgs;
        inherit (inputs) homeManager nur hardware;
      };

      modules =
        [
          # host configuration
          (../nixos/hosts + "/${host}")

          # home manager
          inputs.homeManager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              users."${user}" = {
                imports = homeModules;
              };
              extraSpecialArgs = {
                inherit inputs pkgs nixpkgs user;
              };
            };
          }
        ];
    };


  mkHome =
    { user
    , system
    , homeModules ? [ ]
    , nixpkgs ? inputs.unstable
    }:
    let
      pkgs = mkNixpkgs { inherit system; };
      homeDirectory = "/home/${user}";
    in
    inputs.homeManager.lib.homeManagerConfiguration {
      inherit system user homeDirectory pkgs;
      configuration = {
        imports = homeModules;
      };

      extraSpecialArgs = {
        inherit inputs nixpkgs system user homeDirectory;
      };
    };

}