_:

{
  # TPM2 Settings
  # Enable TPM2 Module
  security.tpm2.enable = true;

  # sudo settings
  security.sudo = {
    extraConfig = "Defaults lecture=never\nDefaults passwd_timeout=0\nDefaults insults";
  };

}
