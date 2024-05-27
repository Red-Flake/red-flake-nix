{
  description = "Red-Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NUR.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: let
    system = "x86_64-linux";
    username = "pascal";
  in {
    nixosConfigurations = {
      redflake = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          {
            imports = [ inputs.home-manager.nixosModules.home-manager ];

            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users = {
              pascal = {
                home.username = "pascal";
                home.homeDirectory = "/home/pascal";
                home.stateVersion = "23.05";
                imports = [ ./home-manager/home.nix ];
              };
            };
            home-manager.extraSpecialArgs = { inherit inputs username; };
          }
        ];
      };
    };
  };
}
