{
  description = "Red-Flake";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
      "ca-derivations"
    ];
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org/"
      "https://nyx.chaotic.cx"
      "https://claude-code.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
    builders-use-substituters = true;
    max-jobs = "auto";
    cores = 0;
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
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

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
    tuxedo-nixos = {
      url = "github:Red-Flake/tuxedo-nixos";
    };

    # Nix Gaming for Steam platformOptimizations
    # https://github.com/fufexan/nix-gaming
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #Modded Spotify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/sadjow/claude-code-nix/
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

      # Common overlays used across all configurations
      commonOverlays = [
        inputs.chaotic.overlays.default
        (import nixos/overlays/impacket-overlay)
      ];

      # Common pkgs with overlays applied once
      commonPkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = commonOverlays;
      };

      # Common home-manager configuration generator
      mkHomeManagerConfig =
        {
          user,
          homeDirectory,
          stateVersion ? "23.05",
          modules,
        }:
        {
          imports = [ inputs.home-manager.nixosModules.home-manager ];

          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";

          home-manager.extraSpecialArgs = {
            inherit inputs;
            inherit user;
            pkgs = commonPkgs;
          };

          home-manager.users.${user} = {
            home.username = user;
            home.homeDirectory = homeDirectory;
            home.stateVersion = stateVersion;
            imports = modules;
          };
        };

      # Common NixOS configuration generator
      mkNixOSConfig =
        {
          hostPath,
          user,
          isKVM,
          extraModules ? [ ],
          includeSpicetify ? false,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
            chaoticPkgs = commonPkgs;
            inherit user isKVM;
          };
          modules = [
            redflake-packages.nixosModules.bloodhound-ce
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja
          ]
          ++ (if includeSpicetify then [ spicetify-nix.nixosModules.default ] else [ ])
          ++ [ hostPath ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {

        # KVM host configuration
        kvm = mkNixOSConfig {
          hostPath = ./nixos/hosts/kvm;
          user = "redflake";
          isKVM = true;
          extraModules = [
            (mkHomeManagerConfig {
              user = "redflake";
              homeDirectory = "/home/redflake";
              modules = [ ./home-manager/redflake ];
            })
          ];
        };

        # VMWare host configuration
        vmware = mkNixOSConfig {
          hostPath = ./nixos/hosts/vmware;
          user = "redflake";
          isKVM = false;
          extraModules = [
            (mkHomeManagerConfig {
              user = "redflake";
              homeDirectory = "/home/redflake";
              modules = [ ./home-manager/redflake ];
            })
          ];
        };

        # ThinkPad T580 host configuration
        t580 = mkNixOSConfig {
          hostPath = ./nixos/hosts/t580;
          user = "pascal";
          isKVM = false;
          extraModules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-t590
            (mkHomeManagerConfig {
              user = "pascal";
              homeDirectory = "/home/pascal";
              modules = [ ./home-manager/pascal ];
            })
          ];
        };

        # TUXEDO Stellaris 16 Gen7
        stellaris = mkNixOSConfig {
          hostPath = ./nixos/hosts/stellaris;
          user = "pascal";
          isKVM = false;
          extraModules = [
            tuxedo-nixos.nixosModules.default
            (mkHomeManagerConfig {
              user = "pascal";
              homeDirectory = "/home/pascal";
              modules = [ ./home-manager/pascal ];
            })
          ];
        };

        # VPS host configuration (lightweight - no bloodhound-ce)
        vps = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
            chaoticPkgs = commonPkgs;
            user = "redcloud";
            isKVM = true;
          };
          modules = [
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            binaryninja.nixosModules.binaryninja
            ./nixos/hosts/vps
            (mkHomeManagerConfig {
              user = "redcloud";
              homeDirectory = "/home/redcloud";
              modules = [ ./home-manager/redcloud ];
            })
          ];
        };

        # Letgamer desktop-pc
        redline = mkNixOSConfig {
          hostPath = ./nixos/hosts/redline;
          user = "let";
          isKVM = false;
          includeSpicetify = true;
          extraModules = [
            (mkHomeManagerConfig {
              user = "let";
              homeDirectory = "/home/let";
              modules = [ ./home-manager/redline ];
            })
          ];
        };

      };

      # Add flake checks for validation
      checks.${system} = {
        flake-check = nixpkgs.legacyPackages.${system}.writeShellScriptBin "flake-check" ''
          ${nixpkgs.legacyPackages.${system}.nixVersions.stable}/bin/nix flake check --no-build
        '';
      };
    };
}
