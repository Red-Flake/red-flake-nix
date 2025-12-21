{ inputs, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    httrack
    updog
    burpsuite
    inputs.burpsuitepro.packages.${system}.default
    zap
    xssstrike
    xsser
    xxeinjector
  ];
}
