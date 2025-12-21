{ pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    python27Full
  ];
}
