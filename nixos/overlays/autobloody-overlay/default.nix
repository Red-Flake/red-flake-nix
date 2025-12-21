# autobloody-overlay.nix
self: super:

let
  lib = super.lib;

  # Override python313 to disable tests for pytest-mock
  python313 = super.python313.override {
    packageOverrides = pySelf: pySuper: {
      pytest-mock = pySuper.pytest-mock.overrideAttrs (old: {
        doCheck = false;
      });

      ldap3 = pySuper.ldap3.overrideAttrs (old: {
        version = "2.9.1";
        src = super.fetchPypi {
          pname = "ldap3";
          version = "2.9.1";
          sha256 = "sha256-8+f8Rxjj8J3aVotXEACV4M5YYzvKu+2GZ84/j7qkIp8=";
        };
        doCheck = false; # Disable the check phase
        doInstallCheck = false; # Disable the install check phase
        nativeCheckInputs = [ ]; # Remove all test hooks, including unittestCheckHook
        pytestFlagsArray = [ ];
        preCheck = "";
        checkPhase = ""; # Empty check phase
        pythonImportsCheckPhase = "";
        unittestCheckPhase = "";

        # Completely override patchPhase to prevent substituteStream from running
        patchPhase = ''
          # Only run dos2unix (optional) and nothing else
          find . -type f -name '*.py' -exec dos2unix {} \;
        '';
      });
    };
  };

  fetchFromGitHub = super.fetchFromGitHub;

  # Define the custom bloodyad version 1.0.5
  bloodyad_1_0_5 = self.python313.pkgs.buildPythonApplication rec {
    pname = "bloodyad";
    version = "1.0.5";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "CravateRouge";
      repo = "bloodyAD";
      rev = "refs/tags/v${version}";
      hash = "sha256-bf2YNml8Y3doO2hHYLbb7bBzuvO9CoKyXCk6pL9/BZE="; # Replace with correct hash
    };

    build-system = [ self.python313.pkgs.hatchling ];

    propagatedBuildInputs = with python313.pkgs; [
      asn1crypto
      cryptography
      dnspython
      gssapi
      ldap3
      msldap
      pyasn1
      winacl
    ];

    pythonImportsCheck = [ ]; # Disable import checks
    doCheck = false; # Disable tests
    checkPhase = ""; # Empty check phase
    pythonImportsCheckPhase = "";
    unittestCheckPhase = "";

    # Remove the tests/ directory after unpacking the source
    postPatch = ''
      rm -rf tests/
    '';

    meta = with lib; {
      description = "Module for Active Directory Privilege Escalations";
      homepage = "https://github.com/CravateRouge/bloodyAD";
      changelog = "https://github.com/CravateRouge/bloodyAD/releases/tag/v${version}";
      license = licenses.mit;
      maintainers = with maintainers; [ lib.maintainers.fab ];
    };
  };
in
{
  autobloody = self.python313.pkgs.buildPythonApplication rec {
    pname = "autobloody";
    version = "0.2.2";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "CravateRouge";
      repo = "autobloody";
      rev = "refs/tags/v${version}";
      hash = "sha256-HjcJEgMAxOWSo7t+mV4WsSamX8s5v6MqjSk55NtBFWI=";
    };

    nativeBuildInputs = with self.python313.pkgs; [
      hatchling
    ];

    propagatedBuildInputs = with self.python313.pkgs; [
      bloodyad_1_0_5
      neo4j
    ];

    doCheck = false; # Disable tests
    checkPhase = ""; # Empty check phase
    pythonImportsCheck = [ ]; # Disable import checks

    # Remove the tests/ directory after unpacking the source
    postPatch = ''
      rm -rf tests/
    '';

    meta = with lib; {
      description = "Tool to automatically exploit Active Directory privilege escalation paths";
      homepage = "https://github.com/CravateRouge/autobloody";
      changelog = "https://github.com/CravateRouge/autobloody/releases/tag/v${version}";
      license = licenses.mit;
      maintainers = with lib.maintainers; [ lib.maintainers.Mag1cByt3s ];
      mainProgram = "autobloody";
    };
  };
}
