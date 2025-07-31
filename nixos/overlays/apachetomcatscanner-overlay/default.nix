# apachetomcatscanner-overlay.nix
self: super: {

  apachetomcatscanner = let
    python = super.python313;
    # Pin urllib3 to 1.26.18 ( <2 )
    urllib3 = python.pkgs.urllib3.overrideAttrs (old: {
      version = "1.26.18";
      src = python.pkgs.fetchPypi {
        pname = "urllib3";
        version = "1.26.18";
        hash = "sha256-+OzBu6VmdBNFfFKauVW/jGe0XbeZ0VkGYmFxnjKFgKA=";
      };
      propagatedBuildInputs = [
        python.pkgs.six
      ];
    });
    # Pin requests to 2.29.0
    requests = python.pkgs.requests.overrideAttrs (old: {
      version = "2.29.0";
      src = python.pkgs.fetchPypi {
        pname = "requests";
        version = "2.29.0";
        hash = "sha256-8uNKdfR0kBm7Dj7/tmaDYw5P/q91gZ+1G+vvG/Wu8Fk=";
      };
      propagatedBuildInputs = [
        urllib3
      ] ++ (with python.pkgs; [
        charset-normalizer
        idna
        certifi
      ]);
      patches = [];  # Disable all patches to avoid failure on older version
    });
    # Pin sectools to 1.3.9
    sectools = python.pkgs.sectools.overrideAttrs (old: {
      version = "1.3.9";
      src = python.pkgs.fetchPypi {
        pname = "sectools";
        version = "1.3.9";
        hash = "sha256-+ztnoqReeTQ5vrQNrNZnks7j4oOKmtHfzVothznNecc=";  # Replace with actual hash from nix-prefetch-url if needed
      };
    });
    # xlsxwriter can use latest, no pin needed unless specified
  in python.pkgs.buildPythonApplication rec {
    pname = "apachetomcatscanner";
    version = "git-ad1271c4";  # Custom version for the commit
    pyproject = true;

    src = super.fetchFromGitHub {
      owner = "p0dalirius";
      repo = "ApacheTomcatScanner";
      rev = "ad1271c4c68ba9e9475e9d40b30f766a279c162d";
      hash = "sha256-5D5pVGp9G7zDpGryO10Q0V4PVDYS5z2LhACr4cBjnzQ=";
    };

    # No postPatch needed for this commit
    postPatch = "";

    pythonRelaxDeps = true;  # Relax deps to avoid strict version checks

    build-system = with python.pkgs; [ setuptools ];

    propagatedBuildInputs = with python.pkgs; [
      requests  # Pinned to 2.29.0 with pinned urllib3
      sectools  # Pinned to 1.3.9
      xlsxwriter  # Latest is fine
    ];

    # Project has no test
    doCheck = false;

    pythonImportsCheck = [ "apachetomcatscanner" ];

    meta = {
      description = "Tool to scan for Apache Tomcat server vulnerabilities";
      homepage = "https://github.com/p0dalirius/ApacheTomcatScanner";
      license = super.lib.licenses.gpl2Only;
      maintainers = with super.lib.maintainers; [ fab ];
      mainProgram = "apachetomcatscanner";
    };
  };
}