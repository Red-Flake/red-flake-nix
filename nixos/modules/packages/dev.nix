{ pkgs
, ...
}:

let
  # Wrap mingw64 gcc/g++ so the linker can find mcfgthreads without overlaying
  # pkgsCross (which would force a full Wine rebuild from source).
  mcfgthreadsLib = "${pkgs.pkgsCross.mingwW64.windows.mcfgthreads}/lib";
  mingwW64-gcc-wrapped = pkgs.symlinkJoin {
    name = "mingwW64-gcc-wrapped";
    paths = [ pkgs.pkgsCross.mingwW64.buildPackages.gcc ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/x86_64-w64-mingw32-gcc --add-flags "-L${mcfgthreadsLib}"
      wrapProgram $out/bin/x86_64-w64-mingw32-g++ --add-flags "-L${mcfgthreadsLib}"
    '';
  };
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    autoconf
    automake
    cmake
    dotnet-sdk_8
    dotnet-runtime_8
    dotnet-aspnetcore_8
    mono
    javaPackages.compiler.openjdk25
    maven
    python314
    python314Packages.pip
    (python314Packages.pipx.overridePythonAttrs (_old: {
      doCheck = false;
    }))
    python314Packages.bpython
    mingwW64-gcc-wrapped # x86_64-w64-mingw32-gcc & g++ (wrapped with mcfgthreads path)
    pkgs.pkgsCross.mingw32.buildPackages.gcc # i686-w64-mingw32-gcc & g++
    pkgs.pkgsCross.mingwW64.buildPackages.binutils # Binutils for 64-bit
    pkgs.pkgsCross.mingw32.buildPackages.binutils # Binutils for 32-bit
    pkgs.pkgsCross.mingwW64.stdenv.cc
    pkgs.llvmPackages.libcxxClang
    pkgs.zig
    nasm
    ruby
    shfmt
    shellcheck
    prettier
  ];
}
