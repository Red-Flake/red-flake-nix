{ config, lib, pkgsx86_64_v3, modulesPath, ... }:

{
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
