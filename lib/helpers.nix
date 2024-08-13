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
    let 
      pkgs = lib.nix.mkNixpkgs {
        inherit system;
        inherit (inputs) nixpkgs;
      };
      homeDirectory = "/home/${user}";
    in
    nixpkgs.lib.nixosSystem {
      inherit system user homeDirectory pkgs;

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
                inherit inputs pkgs nixpkgs system user homeDirectory;
              };
            };
          }
        ];
    };

}