{ 
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  nixpkgs = {

     # Set host platform
     hostPlatform = lib.mkDefault "x86_64-linux";

     # You can add overlays here
     overlays = with inputs; [

      # fix ldeep: https://github.com/NixOS/nixpkgs/pull/402068
      (final: prev: {
        ldeep = prev.ldeep.overrideAttrs (oldAttrs: {
          pythonRelaxDeps = (oldAttrs.pythonRelaxDeps or []) ++ [
            "termcolor"
          ];
        });
      })

      # fix bloodyAD: cryptography==44.0.1 not satisfied by version 44.0.2
      # see: https://github.com/NixOS/nixpkgs/pull/402181/files
      (final: prev: {
        python313Packages = prev.python313Packages.overrideScope (pyfinal: pyprev: {
          bloodyad = pyprev.bloodyad.overrideAttrs (oldAttrs: {
            pythonRelaxDeps = (oldAttrs.pythonRelaxDeps or []) ++ [
              "cryptography"
            ];
          });
        });
      })
      
      # Chaotic-Nyx overlay 
      (final: prev: {
        chaoticPkgs = import inputs.chaotic { inherit (prev) system; };
      })

       # NUR overlay
       inputs.nur.overlays.default

       inputs.poetry2nix.overlays.default

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
