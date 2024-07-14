{ config, lib, pkgs, modulesPath, ... }:

{
  # TPM2 Settings
  # Enable TPM2 Module
  security.tpm2.enable = true;

  # PAM Settings
  security.pam.services = {
    login.kwallet = {
      enable = true;
    };
    kde.kwallet = {
      enable = true;
    };
    kde-fingerprint = lib.mkIf config.services.fprintd.enable { fprintAuth = true; };
    kde-smartcard = lib.mkIf config.security.pam.p11.enable { p11Auth = true; };
  };
}