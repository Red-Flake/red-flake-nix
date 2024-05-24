{
  description = "Red-Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Third party programs, packaged with nix
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, hardware, ... } @ inputs: let
    inherit (nixpkgs.lib) genAttrs;
    systems = ["x86_64-linux"];  # Add other systems as needed
    pkgsFor = genAttrs systems (system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    });
  in {
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/default/default.nix ];
        specialArgs = { inherit inputs; };
      };
    };

    homeConfigurations = {
      "pascal@default" = home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        modules = [ ./home/pascal/default.nix ./home/pascal/nixpkgs.nix ];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}

