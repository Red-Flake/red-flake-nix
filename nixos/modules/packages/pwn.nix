{ inputs
, pkgs
, ...
}:

let
  pwndbg = inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    edb
    pwndbg
    gef
    gdb
  ];
}
