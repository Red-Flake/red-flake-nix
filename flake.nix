{
  description = "Red-Flake";

  nixConfig = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      extra-substituters = [
        "https://cache.garnix.io"
        "https://nyx.chaotic.cx"
        "https://nix-community.cachix.org/"
      ];
      extra-trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
  };

  inputs = {
    # Nixpkgs-Unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Chaotic's Nyx
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Modules support for flakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Have a local index of nixpkgs for fast launching of apps
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home configuration management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.flake-compat.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      # Only used for the tests of pre-commit-hooks. Override stops double fetch
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    # https://gitlab.com/VandalByte/darkmatter-grub-theme
    darkmatter-grub-theme = {
      url = gitlab:VandalByte/darkmatter-grub-theme;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/thiagokokada/nix-alien
    #nix-alien.url = "github:thiagokokada/nix-alien";

    # Red-Flake artwork
    artwork = {
      url = "github:Red-Flake/artwork";
      flake = false;
    };

    # Red-Flake webshells
    webshells = {
      url = "github:Red-Flake/webshells";
      flake = false;
    };

    # Red-Flake tools
    tools = {
      url = "github:Red-Flake/tools";
      flake = false;
    };
    
  };

  outputs = { 
      self, 
      nixpkgs, 
      chaotic, 
      flake-parts, 
      pre-commit-hooks, 
      home-manager, 
      plasma-manager, 
      artwork, 
      webshells, 
      tools, 
      darkmatter-grub-theme,
      ...
  } @ inputs: let
      inherit (self) outputs;
      system = "x86_64-linux";
  in {
      nixosConfigurations = {

          # Virtual Machine host configuration
          vm = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs outputs;
              user = "redflake";
            };
            modules = [
              chaotic.nixosModules.default
              darkmatter-grub-theme.nixosModule

              ./nixos/hosts/vm
              {
                imports = [ inputs.home-manager.nixosModules.home-manager ];

                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = { 
                  inherit inputs;
                  user = "redflake";
                };

                home-manager.users = {
                  redflake = {
                    home.username = "redflake";
                    home.homeDirectory = "/home/redflake";
                    home.stateVersion = "23.05";
                    imports = [
                      ./home-manager
                    ];
                  };
                };

              }
            ];
          };
            
          # ThnkPad T580 host configuration  
          t580 = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs outputs;
              user = "pascal";
            };
            modules = [
              chaotic.nixosModules.default
              darkmatter-grub-theme.nixosModule

              ./nixos/hosts/t580
              {
                imports = [ inputs.home-manager.nixosModules.home-manager ];

                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = { 
                  inherit inputs;
                  user = "pascal";
                };

                home-manager.users = {
                  pascal = {
                    home.username = "pascal";
                    home.homeDirectory = "/home/pascal";
                    home.stateVersion = "23.05";
                    imports = [
                      ./home-manager
                    ];
                  };
                };
              }
            ];
          };

    };
  };
}
