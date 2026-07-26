# Shared overlay configuration for all Red-Flake hosts
{ inputs, ... }:
let
  # Base overlays available to all hosts
  baseOverlays = [
    # Provide a non-deprecated `pkgs.system` attr for older overlays/modules.
    (_: prev: { inherit (prev.stdenv.hostPlatform) system; })

    # NUR overlay
    inputs.nur.overlays.default

    # redflake-packages overlay
    inputs.redflake-packages.overlays.default

    (final: prev:
      let
        python312PackageOverrides = _: pyPrev: {
          bloodhound-py = pyPrev.bloodhound-py.overridePythonAttrs (_: {
            pname = "bloodhound";
          });

          pynfsclient = pyPrev.pynfsclient.overridePythonAttrs (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace pyNfsClient/__info__.py \
                  --replace-fail '__version__ = "0.1.5"' '__version__ = "${old.version}"'
              '';
          });
        };
      in
      {
        python3 = prev.python3.override {
          packageOverrides = python312PackageOverrides;
        };

        python3Packages = final.python3.pkgs;

        python312 = prev.python312.override {
          packageOverrides = python312PackageOverrides;
        };

        python312Packages = final.python312.pkgs;

        python314 = prev.python314.override {
          packageOverrides = _: pyPrev: {
            stamina = pyPrev.stamina.overridePythonAttrs (_: {
              doCheck = false;
            });
          };
        };

        python314Packages = final.python314.pkgs;

        dnsrecon = prev.dnsrecon.overridePythonAttrs (old: {
          dependencies = map
            (pkg:
              if (pkg.pname or "") == "stamina" then
                final.python314Packages.stamina
              else
                pkg)
            old.dependencies;
        });

        netexec = prev.netexec.overridePythonAttrs (old: {
          pythonCatchConflictsPhase = "true";
          dependencies = map
            (pkg:
              if (pkg.pname or "") == "bloodhound-py" then
                final.python312Packages.bloodhound-py
              else if (pkg.pname or "") == "pynfsclient" then
                final.python312Packages.pynfsclient
              else
                pkg)
            old.dependencies;
        });
      })

    (import ../overlays/evil-winrm-py-overlay)
  ];

  # Security tool overlays
  securityOverlays = [
    (import ../overlays/responder-overlay)
    (import ../overlays/bloodhound-quickwin-overlay)
    (import ../overlays/ldapdomaindump-overlay)
    (import ../overlays/SMB_Killer-overlay)
    (import ../overlays/spose-overlay)
    (import ../overlays/nmapAutomator-overlay)
    (import ../overlays/social-engineer-toolkit)
    (import ../overlays/username-anarchy-overlay)
    (import ../overlays/wmiexec-Pro-overlay)
    (import ../overlays/ntlm_theft-overlay)
    (import ../overlays/kerbrute-overlay)
    (import ../overlays/dnscat2-overlay)
    (import ../overlays/wordlists-overlay)
    (import ../overlays/PKINITtools-overlay)
    (import ../overlays/PetitPotam-overlay)
    (import ../overlays/cupp-overlay)
    (import ../overlays/john-overlay)
    (import ../overlays/XSStrike-overlay)
    (import ../overlays/XSSer-overlay)
    (import ../overlays/bashfuscator-overlay)
    (import ../overlays/sliver-overlay)
    (import ../overlays/XXEinjector-overlay)
    (import ../overlays/aquatone-overlay)
    (import ../overlays/eyewitness-overlay)
    (import ../overlays/droopescan-overlay)
    (import ../overlays/JoomlaScan-overlay)
    (import ../overlays/joomla-brute-overlay)
    (import ../overlays/apachetomcatscanner-overlay)
    (import ../overlays/jwtcrack-overlay)
    (import ../overlays/freerdp-overlay)
    #(import ../overlays/burpsuite-overlay)
  ];

  # Desktop specific overlays
  desktopOverlays = [
    # Fix Electron color issues on Wayland with wide-gamut displays
    (import ../overlays/electron-color-fix-overlay)

    # Equibop: writable settings.json + opt-in speech-dispatcher
    (import ../overlays/equibop-overlay)
  ];
in
{
  inherit baseOverlays securityOverlays desktopOverlays;
}
