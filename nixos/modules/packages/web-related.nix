{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    httrack
    updog
    (burpsuite.override { jdk = javaPackages.compiler.openjdk21; })
    zap
    xssstrike
    xsser
    xxeinjector
  ];
}
