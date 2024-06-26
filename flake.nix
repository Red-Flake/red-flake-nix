{
  description = "Red-Flake";

  nixConfig.extra-substituters = [
    "https://cache.garnix.io"
    "https://nyx.chaotic.cx"
  ];
  nixConfig.extra-trusted-public-keys = [
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
  ];

  inputs = {
    # Chaotic's Nyx
    chaotic-nyx = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };

    # If you need to, override this to use a different nixpkgs version
    # by default we follow Chaotic Nyx' nyxpkgs-unstable branch
    nixpkgs.follows = "chaotic-nyx/nixpkgs";

    # Modules support for flakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "chaotic-nyx/nixpkgs";
    };

    # Have a local index of nixpkgs for fast launching of apps
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "chaotic-nyx/nixpkgs";
    };

    # Home configuration management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "chaotic-nyx/nixpkgs";
    };

    # https://github.com/pjones/plasma-manager
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Easy linting of the flake and all kind of other stuff
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-compat.follows = "chaotic-nyx/nixpkgs";
      inputs.nixpkgs.follows = "chaotic-nyx/nixpkgs";
      # Only used for the tests of pre-commit-hooks. Override stops double fetch
      inputs.nixpkgs-stable.follows = "chaotic-nyx/nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    # https://github.com/Melkor333/nixos-boot
    nixos-boot.url = "github:Melkor333/nixos-boot";

    # https://gitlab.com/VandalByte/darkmatter-grub-theme
    darkmatter-grub-theme = {
      url = gitlab:VandalByte/darkmatter-grub-theme;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Red-Flake artwork
    artwork = {
      url = "github:Red-Flake/artwork";
      flake = false;
    };
  };

  outputs = { flake-parts, nixpkgs, pre-commit-hooks, home-manager, plasma-manager, artwork, nixos-boot, darkmatter-grub-theme, ... } @ inputs: let
    system = "x86_64-linux";
    username = "pascal";
    homeDirectory = "/home/pascal";
  in {
    nixosConfigurations = {
      redflake = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          nixos-boot.nixosModules.default
          darkmatter-grub-theme.nixosModule
          ./nixos/configuration.nix
          {
            imports = [ inputs.home-manager.nixosModules.home-manager ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users = {
              pascal = {
                home.username = "pascal";
                home.homeDirectory = "/home/pascal";
                home.stateVersion = "23.05";
                imports = [
                  inputs.plasma-manager.homeManagerModules.plasma-manager
                  ./home-manager/home.nix 
                ];
              };
            };

            home-manager.extraSpecialArgs = { inherit inputs username homeDirectory; };
          }

        ];
      };
    };
  };
}
