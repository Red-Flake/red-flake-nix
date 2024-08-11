{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  nixpkgs = {
  
     # Set host platform
     hostPlatform = lib.mkDefault "x86_64-linux";
  
     # You can add overlays here
     overlays = with inputs; [
       # If you want to use overlays exported from other flakes:
       # neovim-nightly-overlay.overlays.default
  
       # Chaotic Nyx overlay
       chaotic.overlays.default
  
       # NUR overlay
       nur.overlay
  
       # impacket overlay
       (import ./overlays/impacket-overlay)
  
       # responder overlay
       (import ./overlays/responder-overlay)
  
       # evil-winrm overlay
       (import ./overlays/evil-winrm-overlay)
  
       # Or define it inline, for example:
       # (final: prev: {
       #   hi = final.hello.overrideAttrs (oldAttrs: {
       #     patches = [ ./change-hello-to-hi.patch ];
       #   });
       # })
  
       # temporary FIX for https://github.com/NixOS/nixpkgs/issues/325657  /  https://github.com/NixOS/nixpkgs/pull/325676
       (_: prev: {
         #python312 = prev.python312.override { packageOverrides = _: pysuper: { nose = pysuper.pynose; }; };
         pwndbg = prev.python311Packages.pwndbg;
         pwntools = prev.python311Packages.pwntools;
         ropper = prev.python311Packages.ropper;
         gef = prev.gef.override { python3 = prev.python311; };
         compiler-rt = prev.compiler-rt.override { python3 = prev.python311; };
         wordlists = prev.wordlists.override { wfuzz = prev.python311Packages.wfuzz; };
         thefuck = prev.thefuck.overridePythonAttrs { doCheck = false; };
         #xsser = prev.xsser.override { python3 = prev.python311; };
         ananicy-cpp = prev.ananicy-cpp.overrideAttrs { hardeningDisable = [ "zerocallusedregs" ]; };
       })
  
     ];
     # Configure your nixpkgs instance
     config = {
       # Disable if you don't want unfree packages
       allowUnfree = true;
  
       # Allow legacy packages
       permittedInsecurePackages = [
         "openssl-1.1.1w"
       ];
     };
   };
}
