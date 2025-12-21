{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    python27Full
  ];
}
