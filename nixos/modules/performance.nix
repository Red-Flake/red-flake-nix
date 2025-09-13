{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  powerManagement = {
    enable = lib.mkForce true;
    cpuFreqGovernor = lib.mkForce "performance";
    powertop.enable = lib.mkForce false;
  };

  services.tlp = {
    enable = lib.mkForce false;
  };

  # Enable scx_bpfland scheduler
  services.scx = {
    enable = true;

    # Workaround for issue: https://github.com/NixOS/nixpkgs/issues/441768
    # /nix/store/ddx7976jyll30xjbasghv9jailswprcp-bash-interactive-5.3p3/bin/bash: /bin/bash: No such file or directory
    # @TODO: Remove Workaround once this PR is fully merged: https://github.com/NixOS/nixpkgs/pull/442124
    # https://github.com/NixOS/nixpkgs/pull/442124/files
    package = pkgs.scx.full.overrideAttrs (old: {
      postPatch = ''
        rm meson-scripts/fetch_bpftool meson-scripts/fetch_libbpf
        patchShebangs ./meson-scripts
        cp ${old.fetchBpftool} meson-scripts/fetch_bpftool
        cp ${old.fetchLibbpf} meson-scripts/fetch_libbpf
        substituteInPlace ./meson-scripts/build_bpftool \
          --replace-fail '/bin/bash' '${lib.getExe pkgs.bash}'
      '';
    });

    scheduler = "scx_bpfland";
    # Optional: Set extra options for the scheduler
    extraArgs = [
      "--slice-us-lag"
      "-5000" # Negative lag for more consistent performance (reduces responsiveness but smooths long-running tasks)
      "--primary-domain"
      "performance" # Prioritize fastest cores initially (e.g., for bursty compilation phases)
    ];
  };
}
