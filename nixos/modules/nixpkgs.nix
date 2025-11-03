{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  nixpkgs = {

    # Set host platform
    hostPlatform = lib.mkDefault "x86_64-linux";

    # You can add overlays here
    overlays =
      with inputs;
      [
        # Lix overlay
        (final: prev: {
          inherit (prev.lixPackageSets.stable)
            nixpkgs-review
            nix-eval-jobs
            nix-fast-build
            colmena
            ;
        })

        # Chaotic-Nyx overlay
        (final: prev: {
          chaoticPkgs = import inputs.chaotic { inherit (prev) system; };
        })

        # NUR overlay
        inputs.nur.overlays.default

        # poetry2nix overlay
        inputs.poetry2nix.overlays.default

        # redflake-packages overlay
        inputs.redflake-packages.overlays.default

        # fix issues with samba4Full
        (final: prev: {
          samba4Full = prev.samba4Full.override { enableCephFS = false; }; # disable cephfs in order to get around issues with => fatal error: tommath.h: No such file or directory
        })

        # impacket overlay
        (import ../overlays/impacket-overlay)

        # responder overlay
        (import ../overlays/responder-overlay)

        # evil-winrm overlay
        (import ../overlays/evil-winrm-overlay)

        # bloodhound-quickwin overlay
        (import ../overlays/bloodhound-quickwin-overlay)

        # linWinPwn overlay; disable this for now
        #(import ../overlays/linWinPwn-overlay)

        # ldapdomaindump overlay
        (import ../overlays/ldapdomaindump-overlay)

        # SMB_Killer overlay
        (import ../overlays/SMB_Killer-overlay)

        # pyGPOAbuse overlay
        (import ../overlays/pyGPOAbuse-overlay)

        # spose overlay
        (import ../overlays/spose-overlay)

        # netexec overlay
        (import ../overlays/netexec-overlay)

        # nmapAutomator overlay
        (import ../overlays/nmapAutomator-overlay)

        # autobloody overlay
        (import ../overlays/autobloody-overlay)

        # social-engineer-toolkit overlay
        (import ../overlays/social-engineer-toolkit)

        # username-anarchy-overlay
        (import ../overlays/username-anarchy-overlay)

        # wmiexec-Pro-overlay
        (import ../overlays/wmiexec-Pro-overlay)

        # ntlm_theft-overlay
        (import ../overlays/ntlm_theft-overlay)

        # kerbrute-overlay
        (import ../overlays/kerbrute-overlay)

        # DNSenum-overlay
        (import ../overlays/DNSenum-overlay)

        # smtp-user-enum-overlay
        (import ../overlays/smtp-user-enum-overlay)

        # powerview-py-overlay
        (import ../overlays/powerview-py-overlay)

        # dnscat2-overlay
        (import ../overlays/dnscat2-overlay)

        # wordlists-overlay
        (import ../overlays/wordlists-overlay)

        # PKINITtools-overlay
        (import ../overlays/PKINITtools-overlay)

        # PetitPotam-overlay
        (import ../overlays/PetitPotam-overlay)

        # CUPP-overlay
        (import ../overlays/cupp-overlay)

        # john-overlay
        (import ../overlays/john-overlay)

        # certipy-overlay
        (import ../overlays/certipy-overlay)

        # XSStrike-overlay
        (import ../overlays/XSStrike-overlay)

        # XSSer-overlay
        (import ../overlays/XSSer-overlay)

        # bashfuscator-overlay
        (import ../overlays/bashfuscator-overlay)

        # sliver-overlay
        (import ../overlays/sliver-overlay)

        # XXEinjector-overlay
        (import ../overlays/XXEinjector-overlay)

        # aquatone-overlay
        (import ../overlays/aquatone-overlay)

        # eyewitness-overlay
        (import ../overlays/eyewitness-overlay)

        # droopescan-overlay
        (import ../overlays/droopescan-overlay)

        # JoomlaScan-overlay
        (import ../overlays/JoomlaScan-overlay)

        # joomla-brute-overlay
        (import ../overlays/joomla-brute-overlay)

        # apachetomcatscanner-overlay
        (import ../overlays/apachetomcatscanner-overlay)

        # tuxedo-drivers overlay
        (import ../overlays/tuxedo-drivers-overlay)

        # freerdp3 overlay
        (import ../overlays/freerdp3-overlay)

        # mingwW64 overlay
        (import ../overlays/mingwW64-overlay)
      ]
      ++ lib.optionals config.custom.IntelComputeRuntimeLegacy.enable [
        # enable Intel OpenCL legacy runtime if needed
        (import ../overlays/intel-legacy-overlay)
      ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;

      # Allow legacy packages
      permittedInsecurePackages = [
        "openssl-1.1.1w"
        "python-2.7.18.8"
      ];
    };
  };
}
