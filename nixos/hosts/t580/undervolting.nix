{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

  # Needed packages for undervolting
  environment.systemPackages = with pkgs; [
    undervolt # the CLI itself
    s-tui # interactive temp/freq monitor
    stress # to stress-test stability
  ];

  # Undervolt configuration for Core™ i5-8350U + UHD Graphics + analog I/O
  services.undervolt = {
    enable = true; # turn on the undervolt service at boot
    package = pkgs.undervolt; # use the ‘undervolt’ CLI from nixpkgs
    useTimer = true; # run via systemd-timer (retries a few seconds after boot)
    verbose = true; # log each MSR write to journalctl for debugging

    turbo = 0;
    # 0 = keep Intel Turbo Boost enabled (max clocks allowed)
    # 1 = disable Turbo (locks to base frequency)

    coreOffset = -80;
    # subtract 80 mV from CPU core & cache voltage
    # → lowers power & heat, extends sustained turbo windows
    gpuOffset = -50;
    # subtract 50 mV from the integrated GPU voltage
    # → cooler iGPU under graphics or compute load
    uncoreOffset = -50;
    # subtract 50 mV from the ring/uncore voltage
    # → reduces power in the cache/interconnect domain
    analogioOffset = -5; # subtract 5 mV from analog I/O voltage
    # → tiny extra power/heat savings (optional)

    ## Set Power Limits
    # Short-burst cap: 45 W for 1 s
    p1 = {
      limit = 45; # watts; PSU adapter only outputs max 45w
      window = 1; # seconds
    };
    # Sustained cap: 45 W for 28 s
    p2 = {
      limit = 45; # watts; PSU adapter only outputs max 45w
      window = 28; # seconds (default in many BIOSes)
    };
  };

}
