{ inputs
, pkgs
, ...
}:

let
  patchedPwndbgSrc = pkgs.applyPatches {
    name = "pwndbg-patched-source";
    src = inputs.pwndbg;
    patches = [
      ../../patches/pwndbg-disable-capstone-fuzz.patch
    ];
  };

  pwndbg = import "${patchedPwndbgSrc}/nix/pwndbg.nix" {
    inherit pkgs;
    groups = [
      "gdb"
    ];
    inputs = inputs.pwndbg.inputs // {
      self = patchedPwndbgSrc;
    };
  };
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
