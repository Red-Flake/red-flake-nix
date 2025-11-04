{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # enable SSH agent
  programs.ssh.startAgent = true;

  # OpenSSH daemon settings
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
}
