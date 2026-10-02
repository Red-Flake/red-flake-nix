# sops-nix secrets for stellaris (see SECRETS.md)
{ inputs, pkgs, user, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../../secrets/stellaris.yaml;

    # Read the host key from /persist directly: impermanence bind-mounts it into
    # /etc/ssh later in activation than sops-nix decrypts.
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];

    # Radicale CalDAV password for vdirsyncer (home-manager/pascal/modules/tasks.nix)
    secrets.radicale.owner = user;
  };

  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-fido2-hmac
    ssh-to-age
  ];
}
