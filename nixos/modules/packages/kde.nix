{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdePackages.powerdevil
    krita
    # krdc broken: Unknown error
    #kdePackages.krdc
  ];
}
