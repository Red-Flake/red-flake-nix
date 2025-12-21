self: super: {
  pkgsCross = super.pkgsCross // {
    mingwW64 = super.pkgsCross.mingwW64 // {
      windows = super.pkgsCross.mingwW64.windows // {
        mcfgthreads = super.pkgsCross.mingwW64.windows.mcfgthreads.overrideAttrs (_old: {
          dontDisableStatic = true;
        });
      };
      buildPackages = super.pkgsCross.mingwW64.buildPackages // {
        gcc = super.pkgsCross.mingwW64.buildPackages.gcc.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ super.pkgs.makeWrapper ];
          postFixup = (old.postFixup or "") + ''
            wrapProgram $out/bin/x86_64-w64-mingw32-gcc --add-flags "-L${self.pkgsCross.mingwW64.windows.mcfgthreads}/lib"
            wrapProgram $out/bin/x86_64-w64-mingw32-g++ --add-flags "-L${self.pkgsCross.mingwW64.windows.mcfgthreads}/lib"
          '';
        });
      };
    };
  };
}
