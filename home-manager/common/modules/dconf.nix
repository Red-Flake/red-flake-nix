# Common dconf configuration
{ config
, lib
, pkgs
, ...
}:
{
  # Import from existing user modules where this is already configured
  imports = [
    ../../pascal/modules/dconf.nix
  ];
}
