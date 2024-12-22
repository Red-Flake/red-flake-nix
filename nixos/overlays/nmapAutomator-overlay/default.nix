# nmapAutomator-overlay.nix
self: super:
{
  nmapAutomator = super.stdenv.mkDerivation rec {
    pname = "nmapAutomator";
    version = "1.0";

    # Fetch the script from GitHub
    src = super.fetchurl {
      url = "https://raw.githubusercontent.com/Red-Flake/nmapAutomator/refs/heads/master/nmapAutomator.sh";
      sha256 = "sha256-fFbSnuL8xcFKLZSGCR87e7VZ7VABpjBKIQWuwJSnO/4="; # Replace with the actual SHA256 hash
    };

    # Runtime dependencies
    buildInputs = [ super.nmap super.coreutils super.gawk ];

    # Skip unpacking since this is a plain script
    unpackPhase = "true";

    # Install the script and set up the environment
    installPhase = ''
      mkdir -p $out/bin
      install -m755 ${src} $out/bin/nmapAutomator
    '';

    # Use wrapProgram in postInstallPhase
    postInstall = ''
      wrapProgram $out/bin/nmapAutomator --set NMAP_PATH ${super.nmap}
    '';

    meta = with super.lib; {
      description = "A script that you can run in the background!";
      homepage = "https://github.com/Red-Flake/nmapAutomator";
      license = licenses.mit;
      maintainers = [ Mag1cByt3s ];
    };
  };
}
