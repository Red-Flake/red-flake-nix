{ ...
}:
{
  # setup persistence
  environment.persistence = {

    "/persist" = {
      hideMounts = true;
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ]
      ++ [
        # YOUR FILES
        #"/etc/responder/Responder.conf"
      ];
      directories = [
        "/var/log" # systemd journal is stored in /var/log/journal
        "/var/lib/nixos" # for persisting user uids and gids
      ]
      ++ [
        # YOUR DIRECTORIES
        "/root"
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
        "/var/lib/iwd"
        "/var/lib/systemd/coredump"
        "/var/lib/bluetooth"
        "/var/lib/fwupd"
        "/var/lib/upower"
        "/var/lib/neo4j" # persist neo4j data
        "/var/lib/postgresql" # persist postgres data
        "/var/lib/flatpak" # persist flatpak data
        "/etc/ssl/certs" # persist ssl certs
        "/var/lib/tcc" # persist Tuxedo Control Center data
        "/var/lib/AccountsService" # persist user account data
      ];
    };

    "/persist/cache" = {
      hideMounts = true;
      directories = [
        "/var/lib/docker" # persist docker data
        "/var/lib/containers/storage" # persist container storage
        "/var/lib/libvirt" # persist libvirt data
        "/var/lib/lxd" # persist LXC data
        "/var/cache/fwupd" # persist fwupd cache
      ];
    };

  };

}
