# autobloody-overlay.nix
self: super:

let
  lib = super.lib;
  python3 = super.python3;
  fetchFromGitHub = super.fetchFromGitHub;

  # Define the custom bloodyad version 1.0.5
  bloodyad_1_0_5 = python3.pkgs.buildPythonApplication rec {
    pname = "bloodyad";
    version = "1.0.5";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "CravateRouge";
      repo = "bloodyAD";
      rev = "refs/tags/v${version}";
      hash = "sha256-bf2YNml8Y3doO2hHYLbb7bBzuvO9CoKyXCk6pL9/BZE="; # Replace with correct hash
    };

    build-system = [ python3.pkgs.hatchling ];

    propagatedBuildInputs = with python3.pkgs; [
      asn1crypto
      cryptography
      dnspython
      gssapi
      ldap3
      msldap
      pyasn1
      winacl
    ];

    nativeCheckInputs = [ python3.pkgs.pytestCheckHook ];

    pythonImportsCheck = [ "bloodyAD" ];

    # Tests require a test file which is not available in the current release
    doCheck = false;

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
  autobloody = python3.pkgs.buildPythonApplication rec {
    pname = "autobloody";
    version = "0.2.2";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "CravateRouge";
      repo = "autobloody";
      rev = "refs/tags/v${version}";
      hash = "sha256-HjcJEgMAxOWSo7t+mV4WsSamX8s5v6MqjSk55NtBFWI=";
    };

    nativeBuildInputs = with python3.pkgs; [
      hatchling
    ];

    propagatedBuildInputs = with python3.pkgs; [
      bloodyad_1_0_5
      neo4j
    ];

    # Tests require a test file which is not available in the current release
    doCheck = false;

    nativeCheckInputs = with python3.pkgs; [
      pytestCheckHook
    ];

    pythonImportsCheck = [
      "autobloody"
    ];

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
