# overlays/xsser-overlay.nix
final: prev:

let
  python = final.python3;
in
{
  xsser = final.stdenv.mkDerivation rec {
    pname = "XSSer";
    version = "unstable-2024-09-17";

    src = final.fetchFromGitHub {
      owner = "epsylon";
      repo = "xsser";
      rev = "d849e340fd5b31bb11a7deae9dcee6281768660c";
      sha256 = "0q6wn156y14bmn11gv4wpmxq309j3fl88paq3riilz3rg7rvag0x";
    };

    nativeBuildInputs = [
      python
      final.makeWrapper
    ];

    propagatedBuildInputs = with final.python3Packages; [
      tld
      fuzzywuzzy
      requests
      pycurl
      beautifulsoup4
    ];

    buildPhase = ''
      # Figure out which minor Python version we're using:
      PYVER="$(
        "${python.interpreter}" -c 'import sys; print("{}.{}".format(*sys.version_info[:2]))'
      )"

      # Each Python package (tld, fuzzywuzzy, requests, pycurl) is installed
      # under <store-path>/lib/python$PYVER/site-packages; we need those four.
      TLD_SP="${final.python3Packages.tld}/lib/python$PYVER/site-packages"
      FUZZY_SP="${final.python3Packages.fuzzywuzzy}/lib/python$PYVER/site-packages"
      REQ_SP="${final.python3Packages.requests}/lib/python$PYVER/site-packages"
      PCURL_SP="${final.python3Packages.pycurl}/lib/python$PYVER/site-packages"
      BS4_SP="${final.python3Packages.beautifulsoup4}/lib/python$PYVER/site-packages"

      export TLD_SP FUZZY_SP REQ_SP PCURL_SP PYVER
    '';

    installPhase = ''
      # 1) Copy the whole xsser checkout under $out/share/xsser
      mkdir -p "$out/share/xsser"
      cp -r "$src/"* "$out/share/xsser/"

      chmod +x "$out/share/xsser/xsser"

      # 2) Build our wrapper with makeWrapper, injecting exactly those four
      #    site-packages directories into PYTHONPATH and doing 'cd' into share/xsser.
      mkdir -p "$out/bin"
      makeWrapper "${python.interpreter}" "$out/bin/xsser" \
        --chdir "$out/share/xsser" \
        --prefix PYTHONPATH ":" \
          "$TLD_SP:$FUZZY_SP:$REQ_SP:$PCURL_SP:$BS4_SP" \
        --add-flags "xsser"
    '';

    meta = with final.lib; {
      description = "XSSer automatic framework to detect, exploit & report XSS vulnerabilities";
      homepage = "https://github.com/epsylon/xsser";
      license = licenses.gpl3;
      maintainers = with final.maintainers; [ final.maintainers.Mag1cByt3s ];
    };
  };
}
