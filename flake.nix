{
  description = "Red-Flake";

  inputs = {
    # chaotic-nyx
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # NUR
    NUR.url = "github:nix-community/NUR";

    # nixos-unstable 
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    chaotic,
    nixpkgs,
    NUR,
    home-manager, 
    ... 
  } @ inputs: let
    system = "x86_64-linux";
    username = "pascal";
    homeDirectory = "/home/pascal";
  in {
    nixosConfigurations = {
      redflake = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          chaotic.nixosModules.default
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
            home-manager.extraSpecialArgs = { inherit inputs username homeDirectory; };
          }
        ];
      };
    };
  };
}
