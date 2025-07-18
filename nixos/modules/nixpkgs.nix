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
      # Chaotic-Nyx overlay 
      (final: prev: {
        chaoticPkgs = import inputs.chaotic { inherit (prev) system; };
      })

       # NUR overlay
       inputs.nur.overlays.default

       inputs.poetry2nix.overlays.default

      # fix issue with future-1.0.0; force python312
      (final: prev: {
        coercer = prev.coercer.override { python3 = final.python312; };
        adidnsdump = prev.adidnsdump.override { python3 = final.python312; };
        adenum = prev.adenum.override { python3 = final.python312; };
        smbmap = prev.smbmap.override { python3 = final.python312; };
        enum4linux-ng = prev.enum4linux-ng.override { python3 = final.python312; };
        smbclient-ng = prev.smbclient-ng.override { python3 = final.python312; };
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
       #(import ../overlays/ldapdomaindump-overlay)

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
