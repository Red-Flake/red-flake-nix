{
  description = "Red-Flake";

  nixConfig = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      extra-substituters = [
        "https://nyx.chaotic.cx"
        "https://nix-community.cachix.org/"
        "https://cache.nixos.org/"
      ];
      extra-trusted-public-keys = [
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
    };

    nur.url = "github:nix-community/NUR";

    # https://gitlab.com/VandalByte/darkmatter-grub-theme
    darkmatter-grub-theme = {
      url = gitlab:VandalByte/darkmatter-grub-theme;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/thiagokokada/nix-alien
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/impermanence
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    # https://github.com/jchv/nix-binary-ninja
    nix-binary-ninja = {
      url = "github:jchv/nix-binary-ninja";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/poetry2nix
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/NixOS/nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # https://github.com/pwndbg/pwndbg
    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      impermanence,
      chaotic, 
      flake-parts, 
      pre-commit-hooks, 
      home-manager, 
      plasma-manager, 
      nix-binary-ninja,
      artwork, 
      webshells, 
      tools, 
      darkmatter-grub-theme,
      poetry2nix,
      nixos-hardware,
      pwndbg,
      ...
  } @ inputs: let
      inherit (self) outputs;
      system = "x86_64-linux";
  in {
      nixosConfigurations = {

          # KVM host configuration
          kvm = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs outputs;
              chaoticPkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ inputs.chaotic.overlays.default ];
                config.allowUnfree = true;
              };
              user = "redflake";
              isKVM = true;
            };
            modules = [
              chaotic.nixosModules.default
              darkmatter-grub-theme.nixosModule
              inputs.impermanence.nixosModules.impermanence

              ./nixos/hosts/kvm
              {
                imports = [ inputs.home-manager.nixosModules.home-manager ];

                home-manager.useGlobalPkgs = false;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = { 
                  inherit inputs;
                  user = "redflake";
                  pkgs = import inputs.nixpkgs {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                    overlays = [
                      # impacket overlay
                      (import nixos/overlays/impacket-overlay)
                    ];
                  };
                };

                home-manager.users = {
                  redflake = {
                    home.username = "redflake";
                    home.homeDirectory = "/home/redflake";
                    home.stateVersion = "23.05";
                    imports = [
                      ./home-manager/redflake
                    ];
                  };
                };

              }
            ];
          };

          # VMWare host configuration
          vmware = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs outputs;
              chaoticPkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ inputs.chaotic.overlays.default ];
                config.allowUnfree = true;
              };
              user = "redflake";
              isKVM = false;
            };
            modules = [
              chaotic.nixosModules.default
              darkmatter-grub-theme.nixosModule
              inputs.impermanence.nixosModules.impermanence

              ./nixos/hosts/vmware
              {
                imports = [ inputs.home-manager.nixosModules.home-manager ];

                home-manager.useGlobalPkgs = false;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = { 
                  inherit inputs;
                  user = "redflake";
                  pkgs = import inputs.nixpkgs {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                    overlays = [
                      # impacket overlay
                      (import nixos/overlays/impacket-overlay)
                    ];
                  };
                };

                home-manager.users = {
                  redflake = {
                    home.username = "redflake";
                    home.homeDirectory = "/home/redflake";
                    home.stateVersion = "23.05";
                    imports = [
                      ./home-manager/redflake
                    ];
                  };
                };

              }
            ];
          };
            
          # ThinkPad T580 host configuration  
          t580 = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs outputs;
              chaoticPkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ inputs.chaotic.overlays.default ];
                config.allowUnfree = true;
              };
              user = "pascal";
              isKVM = false;
            };
            modules = [
              nixos-hardware.nixosModules.lenovo-thinkpad-t590
              darkmatter-grub-theme.nixosModule
              inputs.impermanence.nixosModules.impermanence

              ./nixos/hosts/t580
              {
                imports = [ inputs.home-manager.nixosModules.home-manager ];

                home-manager.useGlobalPkgs = false;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = { 
                  inherit inputs;
                  user = "pascal";
                  pkgs = import inputs.nixpkgs {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                    overlays = [
                      # impacket overlay
                      (import nixos/overlays/impacket-overlay)
                    ];
                  };
                };

                home-manager.users = {
                  pascal = {
                    home.username = "pascal";
                    home.homeDirectory = "/home/pascal";
                    home.stateVersion = "23.05";
                    imports = [
                      ./home-manager/pascal
                    ];
                  };
                };
              }
            ];
          };

          # VPS host configuration  
          vps = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs outputs;
              chaoticPkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ inputs.chaotic.overlays.default ];
                config.allowUnfree = true;
              };
              user = "redcloud";
              isKVM = true;
            };
            modules = [
              chaotic.nixosModules.default
              darkmatter-grub-theme.nixosModule
              inputs.impermanence.nixosModules.impermanence

              ./nixos/hosts/vps
              {
                imports = [ inputs.home-manager.nixosModules.home-manager ];

                home-manager.useGlobalPkgs = false;
                home-manager.useUserPackages = true;

                home-manager.extraSpecialArgs = { 
                  inherit inputs;
                  user = "redcloud";
                  pkgs = import inputs.nixpkgs {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                    overlays = [
                      # impacket overlay
                      (import nixos/overlays/impacket-overlay)
                    ];
                  };
                };

                home-manager.users = {
                  redcloud = {
                    home.username = "redcloud";
                    home.homeDirectory = "/home/redcloud";
                    home.stateVersion = "23.05";
                    imports = [
                      ./home-manager/redcloud
                    ];
                  };
                };
              }
            ];
          };

    };
  };
}
