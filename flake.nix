{
  description = "Red-Flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    NUR.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: let
    system = "x86_64-linux";
    username = "pascal";
  in {
    # NixOS configuration entrypoint
    nixosConfigurations = {
      redflake = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          {
            # Home Manager integration as a NixOS module
            imports = [ inputs.home-manager.nixosModules.home-manager ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = {
              pascal = { pkgs, ... }: {
                home = import ./home-manager/home.nix { inherit pkgs inputs; };
              };
            };
            home-manager.extraSpecialArgs = { inherit inputs username; };
          }
        ];
      };
    };

    homeConfigurations.pascal = home-manager.lib.homeManagerConfiguration {
      inherit system;
      pkgs = import nixpkgs { inherit system; };
      extraSpecialArgs = { inherit inputs; };
      modules = [ 
        ./home-manager/home.nix
      ];
    };
  };
}
