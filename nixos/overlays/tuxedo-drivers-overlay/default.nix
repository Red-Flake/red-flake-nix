# This overlay updates the tuxedo-drivers package to version 4.18.2
(_final: prev: {
  linuxKernel = prev.linuxKernel // {
    packages = prev.linuxKernel.packages // {
      linux_xanmod_latest = prev.linuxKernel.packages.linux_xanmod_latest // {
        tuxedo-drivers =
          prev.linuxKernel.packages.linux_xanmod_latest.tuxedo-drivers.overrideAttrs
            (_old: rec {
              version = "4.18.2";
              src = prev.fetchFromGitLab {
                group = "tuxedocomputers";
                owner = "development/packages";
                repo = "tuxedo-drivers";
                rev = "v${version}";
                hash = "sha256-9XtogovzAWaMkJI5CxszY5qO3q6NOACZ7pnejyobJlY=";
              };
              # Create the no-cp-usr patch inline
              patches = [
                (prev.writeText "no-cp-usr.patch" ''
                  --- a/Makefile
                  +++ b/Makefile
                  @@ -31,7 +31,6 @@ all:
                   
                   install: all
                   	make -C $(KDIR) M=$(PWD) $(MAKEFLAGS) modules_install
                  -	cp -r usr /
                   
                   clean:
                   	make -C $(KDIR) M=$(PWD) $(MAKEFLAGS) clean
                '')
              ];
            });
      };
    };
  };
})
