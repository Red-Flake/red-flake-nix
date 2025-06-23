{ 
  config,
  lib,
  pkgs,
  inputs,
  ... 
}: {

  # Needed packages for undervolting
  environment.systemPackages = with pkgs; [
    undervolt   # the CLI itself
    s-tui       # interactive temp/freq monitor
    stress      # to stress-test stability
  ];

  # Undervolt configuration for Core™ i5-8350U + UHD Graphics + analog I/O
  services.undervolt = {
    enable         = true;   # turn on the undervolt service at boot
    package        = pkgs.undervolt;  # use the ‘undervolt’ CLI from nixpkgs
    useTimer       = true;  # run via systemd-timer (retries a few seconds after boot)
    verbose        = true;   # log each MSR write to journalctl for debugging

    turbo          = 0;      # 0 = keep Intel Turbo Boost enabled (max clocks allowed)
                             # 1 = disable Turbo (locks to base frequency)

    coreOffset     = -85;    # subtract 85 mV from CPU core & cache voltage
                             # → lowers power & heat, extends sustained turbo windows
    gpuOffset      = -60;    # subtract 60 mV from the integrated GPU voltage
                             # → cooler iGPU under graphics or compute load
    uncoreOffset   = -60;    # subtract 60 mV from the ring/uncore voltage
                             # → reduces power in the cache/interconnect domain
    analogioOffset = -10;    # subtract 10 mV from analog I/O voltage
                             # → tiny extra power/heat savings (optional)
  };

}