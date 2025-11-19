{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Import p10k configurations from pascal's module - following the pascal->common->others pattern
  commonP10k = import ../../pascal/modules/p10k.nix { inherit config lib pkgs; };
in
{
  # Use pascal's p10k configuration as the common default
  imports = [ commonP10k ];
}
