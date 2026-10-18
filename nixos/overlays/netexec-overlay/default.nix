# NetExec built from the main branch. Releases are rare and main moves fast,
# so we track a pinned commit and bump the deps it needs in a private python
# set (nothing outside netexec is affected).
#
# To update: bump `rev` + `hash`, then check upstream's poetry.lock for the
# impacket commit and the versions of the deps overridden below.
final: prev:
let
  inherit (final) lib fetchFromGitHub fetchPypi;

  rev = "0615464f7aed3daa64a3ebe414d1fd7dc830db0b";
  date = "2026-10-17";

  python = prev.python312.override {
    self = python;
    packageOverrides = pyFinal: pySuper: {
      impacket = pySuper.impacket.overridePythonAttrs {
        version = "0.14.0-unstable-2026-10-15";
        src = fetchFromGitHub {
          owner = "fortra";
          repo = "impacket";
          rev = "75938fcb0145b476250940d740f71394676288cb";
          hash = "sha256-2fWpEp/ncH6hKRIObiYDXXnOfJ6XVppdW7XlrpZbA+o=";
        };
        # PEP 440 compliant version
        postPatch = ''
          substituteInPlace setup.py \
            --replace-fail 'version="{}.{}.{}.{}{}"' 'version="{}.{}.{}"'
        '';
      };

      # NetExec's certipy fork with relaxed pins
      certipy-nxc = pySuper.certipy-ad.overridePythonAttrs (o: {
        pname = "certipy-nxc";
        version = "5.1.0.post1";
        src = fetchPypi {
          pname = "certipy_nxc";
          version = "5.1.0.post1";
          hash = "sha256-+xHKEbzy4efrBg4senunhpm66vq7I1mN03cLYdB7dbg=";
        };
        pythonRelaxDeps = true;
        meta = o.meta // {
          homepage = "https://github.com/Pennyw0rth/Certipy";
          changelog = null;
        };
      });

      dploot = pySuper.dploot.overridePythonAttrs (o: rec {
        version = "4.1.1";
        src = fetchPypi {
          pname = "dploot";
          inherit version;
          hash = "sha256-qvTkz1gcmA6IjV1TpG1sTjn6oeUTdPaZNCdo85uyQkg=";
        };
        pythonRelaxDeps = true;
        dependencies = o.dependencies ++ (with pyFinal; [
          pick
          pypsrp
        ]);
      });

      masky = pySuper.masky.overridePythonAttrs rec {
        version = "0.2.1";
        # 0.2.1 is only published on PyPI
        src = fetchPypi {
          pname = "masky";
          inherit version;
          hash = "sha256-lzYVvrvZRVocKoGmzsYmogMuwiCfJC4+aaYibktgtvw=";
        };
      };

      aardwolf = pySuper.aardwolf.overridePythonAttrs (_: rec {
        version = "0.2.16";
        src = fetchFromGitHub {
          owner = "skelsec";
          repo = "aardwolf";
          tag = version;
          hash = "sha256-4bKAK8FNXNYkImBkajuQ+7SbYNE0itQJ3YkUM1/vqCQ=";
        };
        patches = [ ];
        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit src;
          pname = "aardwolf";
          inherit version;
          sourceRoot = "${src.name}/rust";
          hash = "sha256-5IRY1feXLD1CAJV2qfq5KjXaxGfWrjMS/GOsH1C55Po=";
        };
        cargoRoot = "rust";
      });
    };
  };
in
{
  netexec = python.pkgs.buildPythonApplication {
    pname = "netexec";
    version = "1.5.1-unstable-${date}";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "Pennyw0rth";
      repo = "NetExec";
      inherit rev;
      hash = "sha256-/olOyVf1VN8DlpxNDDRLLZSYuO2Zdtl/tRR0csOxpgw=";
    };

    # No .git in the source, so give poetry-dynamic-versioning a PEP 440
    # version (the nix version string above isn't one)
    dontBypassPoetryDynamicVersioning = true;
    env.POETRY_DYNAMIC_VERSIONING_BYPASS = "1.5.1+${builtins.substring 0 7 rev}";

    pythonRelaxDeps = true;

    pythonRemoveDeps = [
      # Not packaged in nixpkgs; the `bloodhound` package provides the module
      "bloodhound-ce"
    ];

    postPatch = ''
      substituteInPlace nxc/first_run.py \
        --replace-fail "from os import mkdir" "from os import mkdir, chmod" \
        --replace-fail "shutil.copy(default_path, NXC_PATH)" $'shutil.copy(default_path, CONFIG_PATH)\n        chmod(CONFIG_PATH, 0o600)'

      substituteInPlace pyproject.toml \
        --replace-fail " @ git+https://github.com/fortra/impacket" "" \
        --replace-fail " @ git+https://github.com/Pennyw0rth/NfsClient" ""
    '';

    build-system = with python.pkgs; [
      poetry-core
      poetry-dynamic-versioning
    ];

    dependencies = with python.pkgs; [
      aardwolf
      argcomplete
      asyauth
      beautifulsoup4
      bloodhound
      certihound
      certipy-nxc
      cryptography
      dnspython
      dploot
      dsinternals
      impacket
      jwt
      ldap3
      lsassy
      lxml
      masky
      minikerberos
      msldap
      neo4j
      netifaces
      paramiko
      pefile
      pyasn1-modules
      pycryptodomex
      pylnk3
      pynfsclient
      pyopenssl
      pypsrp
      pypykatz
      python-dateutil
      python-libnmap
      requests
      rich
      six
      sqlalchemy
      termcolor
      terminaltables3
      xmltodict
    ];

    nativeCheckInputs = with python.pkgs; [ pytestCheckHook ] ++ [ final.writableTmpDirAsHomeHook ];

    # e2e tests need live targets
    disabledTestPaths = [
      "tests/e2e_tests.py"
      # stale upstream tests that don't match the current code
      "tests/test_ip_excluseion.py"
      "tests/test_smb_signing.py"
    ];

    pythonImportsCheck = [ "nxc" ];

    meta = {
      description = "Network service exploitation tool (maintained fork of CrackMapExec)";
      homepage = "https://github.com/Pennyw0rth/NetExec";
      license = lib.licenses.bsd2;
      mainProgram = "nxc";
      platforms = lib.platforms.linux;
    };
  };
}
