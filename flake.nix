{
  description = "Red-Flake";

  # NOTE: nixConfig requires static values (no imports/thunks).
  # The authoritative cache list is in nixos/shared/caches.nix - keep these in sync.
  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org/"
      "https://mrn157.cachix.org/"
      "https://cache.garnix.io"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mrn157.cachix.org-1:A3KuzqTH/AeTFpDsu7Fql7KpZBJvFCkfNqxkL2+DZlc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
    extra-deprecated-features = [
      "url-literals"
    ];
    builders-use-substitutes = true;
    max-jobs = "auto";
    cores = 0;
  };

  inputs = {
    # Nixpkgs (NixOS stable)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Nixpkgs (NixOS unstable) - for packages not available on stable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Pinned nixpkgs for Neo4j 4.4.11 (BloodHound CE compatibility)
    nixpkgs-neo4j-4-4-11.url = "github:NixOS/nixpkgs/7a339d87931bba829f68e94621536cad9132971a";

    # Modules support for flakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Home configuration management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/pjones/plasma-manager
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Easy linting of the flake and all kind of other stuff
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-compat.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/pwndbg/pwndbg
    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Gaming for Steam platformOptimizations
    # https://github.com/fufexan/nix-gaming
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Modded Spotify
    # https://github.com/Gerg-L/spicetify-nix
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/FlameFlag/nixcord
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/xddxdd/nix-cachyos-kernel
    # CachyOS kernels via nix-cachyos-kernel (cached via Hydra)
    # https://hydra.lantian.pub/jobset/lantian/nix-cachyos-kernel
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    burpsuite-nix = {
      url = "github:Red-Flake/burpsuite-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    burpsuitepro = {
      url = "github:Red-Flake/Burpsuite-Professional";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    # Red-Flake Plymouth theme
    redflakePlymouth = {
      url = "github:Red-Flake/redflake-plymouth/cad99c2de44912689d7d7deed3eb0543fcb6a300";
      flake = false;
    };

    # Red-Flake NUR packages
    redflake-packages = {
      type = "github";
      owner = "Red-Flake";
      repo = "packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # UCC (Uniwill Control Center)
    # Upstream: github:nanomatters/ucc
    #ucc = {
    #  url = "path:/home/pascal/Git/ucc";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    ucc.url = "github:nanomatters/ucc/bf26a4009100e80eeafbbededea59d32d92ca4ba";
    #ucc.url = "github:Mag1cByt3s/ucc/fix/uccd-sleep-requires-loop";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , flake-parts
    , pre-commit-hooks
    , redflake-packages
    , ucc
    , spicetify-nix
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      # Per-system outputs
      perSystem =
        { system, ... }:
        let
          # Shared nixpkgs config
          sharedNixpkgsConfig = import ./nixos/shared/nixpkgs-config.nix;

          # Import shared overlays
          sharedOverlays = import nixos/shared/overlays.nix { inherit inputs; };

          # Common overlays used across all configurations
          commonOverlays = sharedOverlays.baseOverlays;

          # Custom pkgs with our overlays for checks/shells
          commonPkgs = import inputs.nixpkgs {
            inherit system;
            config = sharedNixpkgsConfig;
            overlays = commonOverlays;
          };
        in
        {
          # Formatter
          formatter = commonPkgs.treefmt;

          # DevShells
          devShells.default = commonPkgs.mkShell {
            inherit (self.checks.${system}.pre-commit) shellHook;
            packages = with commonPkgs; [
              nixpkgs-fmt
              treefmt
              shfmt
              prettier
              shellcheck
              statix
              deadnix
              pre-commit
              nh
            ];
          };

          # Checks
          checks = {
            flake-check = nixpkgs.legacyPackages.${system}.writeShellScriptBin "flake-check" ''
              ${nixpkgs.legacyPackages.${system}.nixVersions.stable}/bin/nix flake check --all-systems --no-build
            '';
            pre-commit = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                treefmt = {
                  enable = true;
                  package = commonPkgs.treefmt;
                  extraPackages = [
                    commonPkgs.nixpkgs-fmt
                    commonPkgs.shfmt
                    commonPkgs.prettier
                  ];
                };
                shellcheck.enable = true;
                statix.enable = true;
                deadnix = {
                  enable = true;
                };
              };
            };
          };
        };

      # Global flake output
      flake =
        let
          system = "x86_64-linux";
          inherit (self) outputs;

          # Shared nixpkgs config used across all package sets
          sharedNixpkgsConfig = import ./nixos/shared/nixpkgs-config.nix;

          # Import shared overlays
          sharedOverlays = import nixos/shared/overlays.nix { inherit inputs; };

          # Common overlays used across all configurations
          commonOverlays = sharedOverlays.baseOverlays;

          # Common pkgs with overlays applied once (used for general utilities)
          commonPkgs = import inputs.nixpkgs {
            inherit system;
            config = sharedNixpkgsConfig;
            overlays = commonOverlays;
          };

          # Import shared user helper (parametrized by pkgs to match host config)
          mkUserFor =
            pkgs: pkgsUnstable: homeDirectory:
            import ./home-manager/shared/mkUser.nix {
              inherit inputs;
              inherit (nixpkgs) lib;
              inherit pkgs pkgsUnstable;
              inherit homeDirectory;
            };

          # Import shared host helper
          mkHost = import ./nixos/shared/mkHost.nix {
            config = { };
            inherit (nixpkgs) lib;
            pkgs = commonPkgs;
            inherit inputs;
            isKVM = false; # Default value, will be overridden per host
          };

          # Common home-manager configuration generator using shared modules
          mkHomeManagerConfig =
            { user
            , homeDirectory
            , stateVersion ? "23.05"
            , profile
            , extraConfig ? { }
            , pkgs
            , pkgsUnstable
            }:
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.overwriteBackup = true;

              # Keep HM pkgs aligned with the host package set (important for per-host nixpkgs config)
              home-manager.extraSpecialArgs = {
                inherit inputs;
                inherit user;
                inherit pkgs;
                inherit pkgsUnstable;
              };

              home-manager.users.${user} = (mkUserFor pkgs pkgsUnstable homeDirectory).mkUser profile (
                extraConfig
                // {
                  homeConfig = {
                    username = user;
                    inherit homeDirectory;
                    inherit stateVersion;
                  };
                }
              );
            };

          # Common NixOS configuration generator using shared modules
          mkNixOSConfig =
            { profile
            , hostname
            , user
            , isKVM
            , system ? "x86_64-linux"
            , hostConfig
            , extraModules ? [ ]
            , homeManagerConfigs ? [ ]
            , includeSpicetify ? false
            , includeTuxedo ? false
            , localeProfile ? "german-en"
            , extraConfig ? { }
            , nixpkgsConfig ? { }
            ,
            }:
            let
              hostOverlays =
                commonOverlays
                ++ nixpkgs.lib.optionals (profile == "security") sharedOverlays.securityOverlays
                ++ nixpkgs.lib.optionals
                  (builtins.elem profile [
                    "security"
                    "desktop"
                  ])
                  sharedOverlays.desktopOverlays;

              # Combined nixpkgs config
              hostNixpkgsConfig = sharedNixpkgsConfig // nixpkgsConfig;

              # Pre-import pkgs for specialArgs (home-manager, etc.)
              hostPkgs = import inputs.nixpkgs {
                inherit system;
                config = hostNixpkgsConfig;
                overlays = hostOverlays;
              };

              hostPkgsUnstable = import inputs.nixpkgs-unstable {
                inherit system;
                config = hostNixpkgsConfig;
                overlays = hostOverlays;
              };
            in
            nixpkgs.lib.nixosSystem {
              inherit system;
              # Don't pass pkgs directly - configure via modules instead
              specialArgs = {
                inherit inputs outputs;
                inherit hostPkgs;
                pkgsUnstable = hostPkgsUnstable;
                inherit user isKVM;
                # Pass profile as hostType for module conditional imports
                hostType = profile;
              };
              modules = [
                # Configure nixpkgs via module system (allows insecure/unfree globally)
                {
                  nixpkgs.config = hostNixpkgsConfig;
                  nixpkgs.overlays = hostOverlays;
                }
                redflake-packages.nixosModules.bloodhound-ce
                inputs.impermanence.nixosModules.impermanence
                (mkHost.mkHost profile hostConfig {
                  inherit hostname localeProfile;
                  inherit extraConfig;
                  extraModules =
                    extraModules
                      ++ nixpkgs.lib.optionals includeSpicetify [ spicetify-nix.nixosModules.default ]
                      ++ nixpkgs.lib.optionals includeTuxedo [ ucc.nixosModules.default ];
                })
              ]
              ++ (map
                (
                  cfg:
                  mkHomeManagerConfig (cfg // {
                    pkgs = hostPkgs;
                    pkgsUnstable = hostPkgsUnstable;
                  })
                )
                homeManagerConfigs);
            };
        in
        {
          nixosConfigurations = {

            # KVM host configuration
            kvm = mkNixOSConfig {
              profile = "security";
              hostname = "redflake-kvm";
              hostConfig = ./nixos/hosts/kvm/default.nix;
              user = "redflake";
              isKVM = true;
              nixpkgsConfig = {
                firefox.enablePlasmaBrowserIntegration = true;
              };
              homeManagerConfigs = [
                {
                  user = "redflake";
                  homeDirectory = "/home/redflake";
                  profile = "redflake";
                }
              ];
            };

            # VMWare host configuration
            vmware = mkNixOSConfig {
              profile = "security";
              hostname = "redflake-vmware";
              hostConfig = ./nixos/hosts/vmware/default.nix;
              user = "redflake";
              isKVM = false;
              nixpkgsConfig = {
                firefox.enablePlasmaBrowserIntegration = true;
              };
              homeManagerConfigs = [
                {
                  user = "redflake";
                  homeDirectory = "/home/redflake";
                  profile = "redflake";
                }
              ];
            };

            # TUXEDO Stellaris 16 Gen7
            stellaris = mkNixOSConfig {
              profile = "security";
              hostname = "redflake-stellaris";
              hostConfig = ./nixos/hosts/stellaris/default.nix;
              user = "pascal";
              isKVM = false;
              includeTuxedo = true;
              nixpkgsConfig = {
                firefox.enablePlasmaBrowserIntegration = true;
                nvidia.acceptLicense = true;
                cudaSupport = true;
              };
              homeManagerConfigs = [
                {
                  user = "pascal";
                  homeDirectory = "/home/pascal";
                  profile = "pascal";
                }
              ];
            };

            # VPS host configuration (lightweight - no bloodhound-ce)
            vps = mkNixOSConfig {
              profile = "server";
              hostname = "redflake-vps";
              hostConfig = ./nixos/hosts/vps/default.nix;
              user = "redcloud";
              isKVM = true;
              homeManagerConfigs = [
                {
                  user = "redcloud";
                  homeDirectory = "/home/redcloud";
                  profile = "redcloud";
                }
              ];
            };

            # Letgamer desktop-pc
            redline = mkNixOSConfig {
              profile = "security";
              hostname = "redflake-redline";
              hostConfig = ./nixos/hosts/redline/default.nix;
              user = "let";
              isKVM = false;
              includeSpicetify = true;
              nixpkgsConfig = {
                firefox.enablePlasmaBrowserIntegration = true;
              };
              homeManagerConfigs = [
                {
                  user = "let";
                  homeDirectory = "/home/let";
                  profile = "letgamer";
                }
              ];
            };

            # Shanzem desktop-pc
            borg = mkNixOSConfig {
              profile = "security";
              hostname = "redflake-borg";
              hostConfig = ./nixos/hosts/borg/default.nix;
              user = "shanzem";
              localeProfile = "uk";
              isKVM = false;
              nixpkgsConfig = {
                rocmSupport = true;
                firefox.enablePlasmaBrowserIntegration = true;
              };
              homeManagerConfigs = [
                {
                  user = "shanzem";
                  homeDirectory = "/home/shanzem";
                  profile = "shanzem";
                }
              ];
            };

          };
        };
    };
}
