{ pkgs, ... }:

{
  # enable SSH agent
  programs.ssh.startAgent = true;

  # OpenSSH daemon settings
  services.openssh = {
    enable = true;
    package = pkgs.openssh_gssapi;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      KerberosAuthentication = "yes";
      GSSAPIAuthentication = "yes";
      GSSAPICleanupCredentials = "yes";
    };
  };
}
