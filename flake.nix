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
      "https://claude-code.cachix.org"
    ];
    extra-trusted-public-keys = [
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
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
      url = "github:nix-community/plasma-manager/d47428e5390d6a5a8f764808a4db15929347cd77";
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
      url = "gitlab:VandalByte/darkmatter-grub-theme";
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

    # disable for now due to hash mismatch issues
    # https://github.com/jchv/nix-binary-ninja
    binaryninja = {
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

    # https://github.com/Red-Flake/Burpsuite-Professional
    burpsuitepro = {
      type = "github";
      owner = "Red-Flake";
      repo = "Burpsuite-Professional";
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

    # Red-Flake NUR packages
    redflake-packages = {
      type = "github";
      owner = "Red-Flake";
      repo = "packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Red-Flake/tuxedo-nixos
    tuxedo-nixos.url = "github:Red-Flake/tuxedo-nixos";

    # Nix Gaming for Steam platformOptimizations
    # https://github.com/fufexan/nix-gaming
    nix-gaming.url = "github:fufexan/nix-gaming";

    #Modded Spotify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nixcord.url = "github:kaylorben/nixcord";

    # https://github.com/sadjow/claude-code-nix/
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      impermanence,
      chaotic,
      flake-parts,
      pre-commit-hooks,
      home-manager,
      plasma-manager,
      binaryninja,
      artwork,
      webshells,
      tools,
      redflake-packages,
      darkmatter-grub-theme,
      poetry2nix,
      nixos-hardware,
      pwndbg,
      burpsuitepro,
      tuxedo-nixos,
      nix-gaming,
      spicetify-nix,
      nixcord,
      claude-code,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
    in
    {
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
            redflake-packages.nixosModules.bloodhound-ce
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja

            ./nixos/hosts/kvm
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";

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
            redflake-packages.nixosModules.bloodhound-ce
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja

            ./nixos/hosts/vmware
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";

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
            redflake-packages.nixosModules.bloodhound-ce
            nixos-hardware.nixosModules.lenovo-thinkpad-t590
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja

            ./nixos/hosts/t580
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";

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

        # TUXEDO Stellaris 16 Gen7
        stellaris = nixpkgs.lib.nixosSystem {
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
            redflake-packages.nixosModules.bloodhound-ce
            tuxedo-nixos.nixosModules.default
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja

            ./nixos/hosts/stellaris
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";

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
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja

            ./nixos/hosts/vps
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";

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

        # Letgamer desktop-pc
        redline = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
            chaoticPkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.chaotic.overlays.default ];
              config.allowUnfree = true;
            };
            user = "let";
            isKVM = false;
          };
          modules = [
            redflake-packages.nixosModules.bloodhound-ce
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja
            spicetify-nix.nixosModules.default

            ./nixos/hosts/redline
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";

              home-manager.extraSpecialArgs = {
                inherit inputs;
                user = "let";
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
                "let" = {
                  home.username = "let";
                  home.homeDirectory = "/home/let";
                  home.stateVersion = "23.05";
                  imports = [
                    ./home-manager/redline
                  ];
                };
              };
            }
          ];
        };

      };
    };
}
