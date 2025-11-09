# netexec-overlay.nix
final: prev:

{
  python312_nxc = prev.python312.override {
    self = final.python312;
    packageOverrides = self: super: {
      # ----- impacket (pin at a commit but force a PEP 440 version) -----
      impacket = super.impacket.overridePythonAttrs (
        old:
        let
          v = "0.12.0.dev20251107"; # PEP 440-compliant dev tag
        in
        {
          version = v;
          src = final.fetchFromGitHub {
            owner = "fortra";
            repo = "impacket";
            rev = "2f1d6eb2fc582b5f561bc8bbf7b740943681033c";
            # update if you change rev
            hash = "sha256-r7sNolBmZXA5nWkc4ModrLy3mgM5Yvl7VWnFY6a9kAc=";
          };

          # keep your patch
          patches = [ ./fix-pyasn1-bool.patch ];
          patchStrip = 1;

          # IMPORTANT: reference the Nix-bound 'v', not an undefined ${version}
          postPatch = ''
            # Try a few common patterns to hard-set the version
            sed -i -E 's/^\s*version\s*=\s*get_version\(\).*/version="'${v}'",/' setup.py  || true
            sed -i -E 's/^version\s*=\s*".*"/version="'${v}'"/'            setup.cfg || true
            sed -i -E 's/^\s*VERSION\s*=\s*".*"/VERSION="'${v}'"/'         setup.py  || true
          '';
        }
      );

      # ----- pyNfsClient (fork) -----
      pynfsclient = final.python312_nxc.pkgs.buildPythonPackage rec {
        pname = "pyNfsClient";
        version = "1.0.0";

        pyproject = true;
        build-system = with final.python312Packages; [ setuptools ];

        src = final.fetchFromGitHub {
          owner = "Pennyw0rth";
          repo = "NfsClient";
          rev = "v1.0.0";
          hash = "sha256-OIxxmFQPS9IC5+BPJJUgIBL6xVCs718j+XR8ddYmBfA=";
        };

        meta = with final.lib; {
          description = "Python NFS client library (forked)";
          homepage = "https://github.com/Pennyw0rth/NfsClient";
          license = licenses.mit;
          maintainers = with final.lib.maintainers; [ charming_yang ];
        };
      };
    };
  };

  # ----- NetExec application -----
  netexec = final.python312_nxc.pkgs.buildPythonApplication (
    let
      v = "1.4.0.dev20251103"; # PEP 440-compliant dev tag
    in
    rec {
      pname = "netexec";
      version = v;

      pyproject = true;
      pythonRelaxDeps = true;

      # Some forks specify "neo4j" as a dev prerelease; we supply a stable nixpkgs neo4j instead.
      pythonRemoveDeps = [ "neo4j" ];

      src = final.fetchFromGitHub {
        owner = "Pennyw0rth";
        repo = "NetExec";
        rev = "5a5c63f50bce9afd19c19f8683467a30d7d2828b";
        hash = "sha256-1yNnnPntJ5aceX3Z8yYAMLv5bSFfCFVp0pgxAySlVfE=";
      };

      # Make Poetry happy:
      #  - Ensure a [tool.poetry] block exists
      #  - Set a PEP 440 version
      #  - Map PEP 621 [project.scripts] -> [tool.poetry.scripts]
      #  - Replace git+ dependencies by names resolved by nix
      postPatch = ''
              # Inject/normalize [tool.poetry] metadata with our version
              if ! grep -q '^\[tool\.poetry\]' pyproject.toml; then
                cat >> pyproject.toml <<EOF

        [tool.poetry]
        name = "netexec"
        version = "${v}"
        description = "Network service exploitation tool"
        authors = ["VNCSB <vncsb@users.noreply.github.com>"]
        EOF
              else
                # Ensure version matches our Nix version
                sed -i -E 's/^version\s*=\s*".*"/version = "'"${v}"'"/' pyproject.toml || true
                # Some forks put 0.0.0 as placeholder
                sed -i 's/^version = "0\.0\.0"/version = "'"${v}"'"/' pyproject.toml || true
              fi

              # If repo used [project.scripts], map it so Poetry installs console scripts
              sed -i 's/^\[project\.scripts\]/[tool.poetry.scripts]/' pyproject.toml || true

              # Replace git+ URLs with plain requirement names so Nix-provided wheels are used
              substituteInPlace pyproject.toml \
                --replace '"impacket @ git+https://github.com/fortra/impacket.git",'     '"impacket", ' \
                --replace '"oscrypto @ git+https://github.com/wbond/oscrypto",'          '"oscrypto", ' \
                --replace '"pynfsclient @ git+https://github.com/Pennyw0rth/NfsClient",' '"pynfsclient",'
      '';

      nativeBuildInputs = with final.python312_nxc.pkgs; [ poetry-core ];

      propagatedBuildInputs = with final.python312_nxc.pkgs; [
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
        poetry-dynamic-versioning
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

      # No upstream tests here; skip
      nativeCheckInputs = with final.python312_nxc.pkgs; [ ];
      preCheck = ''export HOME=$(mktemp -d) '';

      meta = with final.lib; {
        description = "Network service exploitation tool (maintained fork of CrackMapExec)";
        homepage = "https://github.com/Pennyw0rth/NetExec";
        changelog = "https://github.com/Pennyw0rth/NetExec/releases/tag/v${version}";
        license = with final.lib.licenses; [ final.lib.licenses.bsd2 ];
        mainProgram = "nxc";
        maintainers = with final.lib.maintainers; [ vncsb ];
        broken = final.stdenv.hostPlatform.isDarwin;
      };
    }
  );
}
