{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    cmake
    dotnet-sdk_8
    dotnet-runtime_8
    dotnet-aspnetcore_8
    jdk
    maven
    python312Full
    python312Packages.pip
    python312Packages.pipx
    python27Full
  ];
}
