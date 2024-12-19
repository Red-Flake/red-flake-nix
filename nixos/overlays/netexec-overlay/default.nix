# netexec-overlay.nix
final: prev:

{
  python3 = prev.python3.override {
    self = final.python3;
    packageOverrides = self: super: {
      impacket = super.impacket.overridePythonAttrs (old: {
        version = "unstable"; # Updated version
        src = final.fetchFromGitHub {
          owner = "fortra"; # Replace with the official or updated repository owner
          repo = "impacket";
          rev = "67e19240fa66ee9f461b506d7f50723e5960cb7c"; # Replace with the commit hash of the newer version
          hash = "sha256-ueSJ7/kTAR/OqL5k1bebOOY3vHfLpdWT0zXfDJ5XZDc="; # Replace with the SHA-256 hash of the new source; nix-prefetch-url --unpack "https://github.com/fortra/impacket/archive/db53482dc864fec69156898d52c1b595a777ca9a.tar.gz"
        };

        # Fix version to be compliant with Python packaging rules
        postPatch = ''
          substituteInPlace setup.py \
            --replace 'version="{}.{}.{}.{}{}"' 'version="{}.{}.{}"'
        '';
      });

      pynfsclient = final.python3.pkgs.buildPythonPackage rec {
        pname = "pyNfsClient";
        version = "1.0.0"; # Updated to match fork version

        src = final.fetchFromGitHub {
          owner = "Pennyw0rth";
          repo = "NfsClient";
          rev = "v1.0.0"; # Tag of the fork release
          hash = "sha256-OIxxmFQPS9IC5+BPJJUgIBL6xVCs718j+XR8ddYmBfA="; # Replace with the SHA-256 hash of the source; nix-prefetch-url --unpack "https://github.com/Pennyw0rth/NfsClient/archive/refs/tags/v1.0.0.tar.gz"
        };

        meta = with final.lib; {
          description = "Python NFS client library (forked)";
          homepage = "https://github.com/Pennyw0rth/NfsClient";
          license = licenses.mit;
          maintainers = with final.lib.maintainers; [ charming_yang ]; # Replace with your GitHub username if applicable
        };
      };

    };
  };

  netexec = final.python3.pkgs.buildPythonApplication rec {
    pname = "netexec";
    version = "1.3.0"; # Updated version
    pyproject = true;
    pythonRelaxDeps = true;
    pythonRemoveDeps = [
      # Fail to detect dev version requirement
      "neo4j"
    ];

    src = final.fetchFromGitHub {
      owner = "Pennyw0rth";
      repo = "NetExec";
      rev = "6d4fdfdb2d0088405ea3139f4145f198671a0fda"; # Replace with the updated revision if needed
      hash = "sha256-Pub7PAw6CTN4c/PHTPE9KcnDR2a6hSza1ODp3EWMOH0="; # Replace with the SHA-256 hash of the new source; nix-prefetch-url --unpack "https://github.com/Pennyw0rth/NetExec/archive/6d4fdfdb2d0088405ea3139f4145f198671a0fda.tar.gz"
    };

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace '{ git = "https://github.com/Pennyw0rth/impacket.git", branch = "gkdi" }' '"*"' \
        --replace '{ git = "https://github.com/Pennyw0rth/oscrypto" }' '"*"'
    '';

    nativeBuildInputs = with final.python3.pkgs; [
      poetry-core
      poetry-dynamic-versioning
    ];

    propagatedBuildInputs = with final.python3.pkgs; [
      aardwolf
      aioconsole
      aiosqlite
      argcomplete
      asyauth
      beautifulsoup4
      bloodhound-py
      dploot
      dsinternals
      impacket
      lsassy
      masky
      minikerberos
      msgpack
      neo4j
      oscrypto
      paramiko
      pyasn1-modules
      pylnk3
      pypsrp
      pypykatz
      python-libnmap
      pywerview
      requests
      rich
      sqlalchemy
      termcolor
      terminaltables
      xmltodict
      python-dateutil
      pynfsclient
    ];

    nativeCheckInputs = with final.python3.pkgs; [];  # Skip tests

    preCheck = ''
      export HOME=$(mktemp -d)
    '';

    meta = with final.lib; {
      description = "Network service exploitation tool (maintained fork of CrackMapExec)";
      homepage = "https://github.com/Pennyw0rth/NetExec";
      changelog = "https://github.com/Pennyw0rth/NetExec/releases/tag/v${version}";
      license = with final.lib.licenses; [ final.lib.licenses.bsd2 ];
      mainProgram = "nxc";
      maintainers = with final.lib.maintainers; [ vncsb ];
      broken = final.stdenv.hostPlatform.isDarwin;
    };
  };
}
