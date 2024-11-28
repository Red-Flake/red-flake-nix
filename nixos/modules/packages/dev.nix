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
    pkgs.pkgsCross.mingwW64.buildPackages.gcc          # x86_64-w64-mingw32-gcc & g++
    pkgs.pkgsCross.mingw32.buildPackages.gcc           # i686-w64-mingw32-gcc & g++
    pkgs.pkgsCross.mingwW64.buildPackages.binutils     # Binutils for 64-bit
    pkgs.pkgsCross.mingw32.buildPackages.binutils      # Binutils for 32-bit
  ];
}
