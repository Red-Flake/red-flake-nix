{ inputs, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gitFull
    gh
    git-dumper
    inputs.redflake-packages.packages.x86_64-linux.gitlab-version
    inputs.redflake-packages.packages.x86_64-linux.gitlab-userenum
  ];
}
