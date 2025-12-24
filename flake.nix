{
  description = "Red-Flake";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
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
    extra-deprecated-features = [
      "url-literals"
    ];
    builders-use-substituters = true;
    max-jobs = "auto";
    cores = 0;
    allowUnfree = true;
  };

  inputs = {
    # Nixpkgs-Unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Pinned nixpkgs for Neo4j 4.4.11 (BloodHound CE compatibility)
    nixpkgs-neo4j-4-4-11.url = "github:NixOS/nixpkgs/7a339d87931bba829f68e94621536cad9132971a";

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
      url = "github:nix-community/home-manager/master";
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
    #binaryninja = {
    #  url = "github:jchv/nix-binary-ninja";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

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

    # https://github.com/sund3RRR/tuxedo-nixos
    tuxedo-nixos = {
      url = "github:sund3RRR/tuxedo-nixos";
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
    inputs@{ self
    , nixpkgs
    , pre-commit-hooks
    , #binaryninja,
      redflake-packages
    , darkmatter-grub-theme
    , nixos-hardware
    , tuxedo-nixos
    , spicetify-nix
    , ...
    }:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      insecurePackages = [
        "openssl-1.1.1w"
        "python-2.7.18.8"
        "python-2.7.18.12"
        "python27Full"
      ];

      # Import shared overlays
      sharedOverlays = import nixos/shared/overlays.nix { inherit inputs; };

      # Common overlays used across all configurations
      commonOverlays = sharedOverlays.allOverlays;

      # Common pkgs with overlays applied once (used for general utilities)
      commonPkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = insecurePackages;
        };
        overlays = commonOverlays;
      };

      # Import shared user helper (parametrized by pkgs to match host config)
      mkUserFor =
        pkgs:
        import ./home-manager/shared/mkUser.nix {
          inherit inputs;
          inherit (nixpkgs) lib;
          inherit pkgs;
        };

      # Import shared host helper
      mkHost = import ./nixos/shared/mkHost.nix {
        config = { };
        inherit (nixpkgs) lib;
        pkgs = commonPkgs;
        chaoticPkgs = commonPkgs;
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
        , pkgs ? commonPkgs
        ,
        }:
        {
          imports = [ inputs.home-manager.nixosModules.home-manager ];

          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";

          # Keep HM pkgs aligned with the host package set (important for per-host nixpkgs config)
          home-manager.extraSpecialArgs = {
            inherit inputs;
            inherit user;
            inherit pkgs;
          };

          home-manager.users.${user} = (mkUserFor pkgs).mkUser profile (
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
            commonOverlays ++ nixpkgs.lib.optionals includeTuxedo sharedOverlays.tuxedoDriversOverlay;

          hostPkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              permittedInsecurePackages =
                nixpkgsConfig.permittedInsecurePackages or (if profile == "server" then [ ] else insecurePackages);
            }
            // nixpkgsConfig;
            overlays = hostOverlays;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = hostPkgs;
          specialArgs = {
            inherit inputs outputs;
            chaoticPkgs = hostPkgs.chaoticPkgs or hostPkgs;
            inherit user isKVM;
          };
          modules = [
            redflake-packages.nixosModules.bloodhound-ce
            darkmatter-grub-theme.nixosModule
            inputs.impermanence.nixosModules.impermanence
            #binaryninja.nixosModules.binaryninja
            (mkHost.mkHost profile hostConfig {
              inherit hostname localeProfile;
              inherit extraConfig;
              extraModules =
                extraModules
                  ++ (if includeSpicetify then [ spicetify-nix.nixosModules.default ] else [ ])
                  ++ (if includeTuxedo then [ tuxedo-nixos.nixosModules.default ] else [ ]);
            })
          ]
          ++ (map (cfg: mkHomeManagerConfig (cfg // { pkgs = hostPkgs; })) homeManagerConfigs);
        };
    in
    {
      formatter.${system} = commonPkgs.treefmt;

      devShells.${system}.default = commonPkgs.mkShell {
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

      nixosConfigurations = {

        # KVM host configuration
        kvm = mkNixOSConfig {
          profile = "security";
          hostname = "redflake-kvm";
          hostConfig = ./nixos/hosts/kvm/default.nix;
          user = "redflake";
          isKVM = true;
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
          homeManagerConfigs = [
            {
              user = "redflake";
              homeDirectory = "/home/redflake";
              profile = "redflake";
            }
          ];
        };

        # ThinkPad T580 host configuration
        t580 = mkNixOSConfig {
          profile = "security";
          hostname = "redflake-t580";
          hostConfig = ./nixos/hosts/t580/default.nix;
          user = "pascal";
          isKVM = false;
          extraModules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-t590
          ];
          homeManagerConfigs = [
            {
              user = "pascal";
              homeDirectory = "/home/pascal";
              profile = "pascal";
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
            nvidia.acceptLicense = true;
            cudaSupport = true;
          };
          extraModules = [ ];
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
          homeManagerConfigs = [
            {
              user = "let";
              homeDirectory = "/home/let";
              profile = "letgamer";
            }
          ];
        };

      };

      # Add flake checks for validation
      checks.${system} = {
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
}
