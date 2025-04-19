# netexec-overlay.nix
final: prev:

{
  python312_nxc = prev.python312.override {
    self = final.python312;
    packageOverrides = self: super: {
      impacket = super.impacket.overridePythonAttrs (old: {
        version = "0.12.0-unstable-06.02.2025"; # Updated version
        src = final.fetchFromGitHub {
          owner = "fortra"; # Replace with the official or updated repository owner
          repo = "impacket";
          rev = "075f2b10a7a4056374a8c917f75e4419817cd6c7"; # Replace with the commit hash of the newer version
          hash = "sha256-PjpactVeJLnTLxwxjbskpmkeBeAjihqqkhhEivl6xH4="; # Replace with the SHA-256 hash of the new source; nix-prefetch-url --unpack "https://github.com/fortra/impacket/archive/db53482dc864fec69156898d52c1b595a777ca9a.tar.gz"
        };

        # Fix version to be compliant with Python packaging rules
        postPatch = ''
          substituteInPlace setup.py \
            --replace 'version="{}.{}.{}.{}{}"' 'version="{}.{}.{}"'
        '';
      });

      pynfsclient = final.python312_nxc.pkgs.buildPythonPackage rec {
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

  netexec = final.python312_nxc.pkgs.buildPythonApplication rec {
    pname = "netexec";
    version = "v1.4.0"; # Updated version
    pyproject = true;
    pythonRelaxDeps = true;
    pythonRemoveDeps = [
      # Fail to detect dev version requirement
      "neo4j"
    ];

    src = final.fetchFromGitHub {
      owner = "Pennyw0rth";
      repo = "NetExec";
      rev = "v1.4.0"; # Replace with the updated revision if needed
      hash = "sha256-1yNnnPntJ5aceX3Z8yYAMLv5bSFfCFVp0pgxAySlVfE="; # Replace with the SHA-256 hash of the new source; nix-prefetch-url --unpack "https://github.com/Pennyw0rth/NetExec/archive/6d4fdfdb2d0088405ea3129f4145f198671a0fda.tar.gz"
    };

    postPatch = ''
      # 1) Replace the placeholder version = "0.0.0" with our version
      substituteInPlace pyproject.toml \
        --replace 'version = "0.0.0"' 'version = "'"${version}"'"'

      # 2) Rename project.scripts → tool.poetry.scripts so Poetry installs them
      sed -i 's/^\[project\.scripts\]/[tool.poetry.scripts]/' pyproject.toml

      # 3) Immediately after that version line, inject name/description/authors
      sed -i '/^version = "'"${version}"'"/a\
name        = "netexec"\
description = "Network service exploitation tool"\
authors     = ["VNCSB <vncsb@users.noreply.github.com>"]' pyproject.toml

      # 4) Turn each git+URL dependency (with its comma) into a wildcard
      substituteInPlace pyproject.toml \
        --replace '"impacket @ git+https://github.com/fortra/impacket.git",'  '"*", ' \
        --replace '"oscrypto @ git+https://github.com/wbond/oscrypto",'      '"*", ' \
        --replace '"pynfsclient @ git+https://github.com/Pennyw0rth/NfsClient",' '"*",'
    '';

    nativeBuildInputs = with final.python312_nxc.pkgs; [
      poetry-core
    ];

    propagatedBuildInputs = with final.python312_nxc.pkgs; [
      poetry-dynamic-versioning
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
      jwt
    ];

    nativeCheckInputs = with final.python312_nxc.pkgs; [];  # Skip tests

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