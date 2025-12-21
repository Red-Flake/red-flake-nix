{ config
, lib
, pkgs
, ...
}:
let
  # Import p10k configurations from common module - following the pascal->common->others pattern
  commonP10k = import ../common/modules/p10k.nix { inherit config lib pkgs; };
in
{
  # Use common p10k configuration (which uses pascal's configs)
  imports = [ commonP10k ];
}
