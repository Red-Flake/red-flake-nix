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
       # Chaotic Nyx overlay
       chaotic.overlays.default

       # NUR overlay
       nur.overlay

       poetry2nix.overlays.default

       # impacket overlay
       (import ../overlays/impacket-overlay)

       # responder overlay
       (import ../overlays/responder-overlay)

       # evil-winrm overlay
       (import ../overlays/evil-winrm-overlay)

       # bloodhound-quickwin overlay
       (import ../overlays/bloodhound-quickwin-overlay)

       # linWinPwn overlay
       (import ../overlays/linWinPwn-overlay)

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
