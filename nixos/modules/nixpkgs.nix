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
