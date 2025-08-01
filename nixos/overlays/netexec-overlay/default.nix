# netexec-overlay.nix
final: prev:

{
  python312_nxc = prev.python312.override {
    self = final.python312;
    packageOverrides = self: super: {
      impacket = super.impacket.overridePythonAttrs (old: {
        version = "0.12.0-unstable-04.04.2025"; # Updated version
        src = final.fetchFromGitHub {
          owner = "fortra"; # Replace with the official or updated repository owner
          repo = "impacket";
          rev = "00ced47f3ed61b64441146e24042f865dcc017b9"; # Replace with the commit hash of the newer version
          hash = "sha256-ETQGJz5a3snGOaIJVM4PBALHVcuqZSLqoff/zeta0Xk="; # Replace with the SHA-256 hash of the new source; nix-prefetch-url --unpack "https://github.com/fortra/impacket/archive/db53482dc864fec69156898d52c1b595a777ca9a.tar.gz"
        };

        # apply our fix to avoid __bool__ on ASN.1 schema
        patches = [ ./fix-pyasn1-bool.patch ];
        patchStrip = 1;

        # Fix version to be compliant with Python packaging rules
        postPatch = ''
          substituteInPlace setup.py \
            --replace 'version="{}.{}.{}.{}{}"' 'version="{}.{}.{}"'
        '';
      });

      pynfsclient = final.python312_nxc.pkgs.buildPythonPackage rec {
        pname = "pyNfsClient";
        version = "1.0.0"; # Updated to match fork version

        pyproject = true;
        build-system = with final.python312Packages; [
          setuptools # Required for setup.py
        ];

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

    # 4) Replace git+ dependencies with proper names
    substituteInPlace pyproject.toml \
      --replace '"impacket @ git+https://github.com/fortra/impacket.git",'  '"impacket", ' \
      --replace '"oscrypto @ git+https://github.com/wbond/oscrypto",'       '"oscrypto", ' \
      --replace '"pynfsclient @ git+https://github.com/Pennyw0rth/NfsClient",' '"pynfsclient",'
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