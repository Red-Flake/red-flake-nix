# Base NixOS configuration shared across all hosts
# hostType is passed via specialArgs from flake.nix
{ config
, lib
, hostType ? "security"
, ...
}:
{
  # Common imports for all hosts
  imports = [
    # Core system configuration
    ../modules/nix.nix
    ../modules/hardware.nix
    ../modules/filesystems.nix
    ../modules/impermanence.nix
    ../modules/bootloader.nix
    ../modules/boot-readonly.nix
    ../modules/kernel.nix

    # Network and connectivity
    ../modules/networking.nix
    ../modules/setup-hosts.nix
    ../modules/ssh.nix

    # Conditional packages based on host type (receives hostType via specialArgs)
    ./conditional-packages.nix

    # Core system environment
    ../modules/fhs.nix
    ../modules/users.nix
    ../modules/setup-shell.nix
    ../modules/services.nix

    # Desktop environment (conditional)
    ../modules/xdg.nix
    ../modules/theming.nix

    # System optimization and tools
    ../modules/appimage.nix
    ../modules/tweaks.nix
    ../modules/sysctl.nix
  ]
  # Conditionally import desktop modules
  ++
  lib.optionals
    (builtins.elem hostType [
      "security"
      "desktop"
    ])
    [
      ../modules/kde.nix
    ]
  # Conditionally import security modules
  ++ lib.optionals (hostType == "security") [
    ../modules/security.nix
    ../modules/virtualisation.nix
  ];

  # Only truly universal settings here - locale/timezone are host-specific
  system.stateVersion = "23.05"; # Do not change this value

  # Make host type available to other modules for conditional defaults.
  custom.hostType = lib.mkDefault hostType;

  # NVMe optimizations (conditional - can be disabled per-host with custom.storage.hasNVMe = false)
  services.udev.extraRules = lib.mkIf config.custom.storage.hasNVMe ''
    # NVMe SSD: Use none scheduler (default for NVMe)
    ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme*n*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="none"

    ${lib.optionalString (config.custom.storage.nvmeQueueRequests != null) ''
      # Optional request queue override; leave unset without workload measurements.
      ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme*n*", ENV{DEVTYPE}=="disk", ATTR{queue/nr_requests}="${toString config.custom.storage.nvmeQueueRequests}"
    ''}
  '';
}
