{ config, lib, pkgs, modulesPath, ... }:

{
  # Enable TPM2 Module
  security.tpm2.enable = true;

  # addtional Hardware related config
  hardware = {

    # Whether to enable firmware with a license allowing redistribution.
    enableRedistributableFirmware = true;

    # Enable CPU microcode updates for AMD CPUs
    cpu.amd.updateMicrocode = true;

    # Enable CPU microcode updates for Intel CPUs
    cpu.intel.updateMicrocode = true;


  };
  
}
