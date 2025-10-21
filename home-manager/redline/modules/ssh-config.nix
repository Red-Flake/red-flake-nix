{
  config,
  lib,
  pkgs,
  ...
}:

let
  revSSHkey = builtins.readFile ../../pascal/modules/ssh/id_reverse-ssh;
  scriptWriteRevSSHKey = pkgs.writeShellScript "write-ssh-key" ''
    #!/run/current-system/sw/bin/bash
    # Check if ~/.ssh exists, if not, create it
    if [ ! -d "$HOME/.ssh" ]; then
      mkdir -p $HOME/.ssh
      chmod 700 $HOME/.ssh
    fi
    # Write the SSH key only if the file doesn't already exist
    if [ ! -f "$HOME/.ssh/id_reverse-ssh" ]; then
      echo "${revSSHkey}" > $HOME/.ssh/id_reverse-ssh
    fi
  '';
in
{
  # systemd user service to run the script to create the key
  systemd.user.services.writesshkey = {
    Unit = {
      Description = "Write reverse-ssh private key";
      After = [ "default.target" ]; # Ensure the user session is ready before running
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${scriptWriteRevSSHKey}";
      ExecStartPost = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chmod 600 %h/.ssh/id_reverse-ssh' || true
      '';
      Type = "oneshot"; # Ensures the service runs once and exits
      RemainAfterExit = true; # Keep the service status as 'active' after it finishes
    };
  };

  # Set all the needed hosts
  home.file.".ssh/config" = {
    text = ''
      Host target
          Hostname 127.0.0.1
          Port 8888
          IdentityFile ~/.ssh/id_reverse-ssh
          IdentitiesOnly yes
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null

      Host ctf
          Hostname 10.70.1.29
          User ctf
          Port 22
          IdentityFile ~/.ssh/id_ctf-ssh
          IdentitiesOnly yes

      Host letserver
          Hostname 192.168.178.84
          User root
          Port 22
          IdentityFile ~/.ssh/id_server-ssh
          IdentitiesOnly yes

      Host *
          HostKeyAlgorithms +ssh-rsa,rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ssh-ed25519
          PubkeyAcceptedKeyTypes +ssh-rsa,rsa-sha2-256,rsa-sha2-512,ecdsa-sha2-nistp256,ssh-ed25519
          KexAlgorithms +diffie-hellman-group14-sha256,curve25519-sha256,diffie-hellman-group14-sha1
          Ciphers +aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com
          MACs +hmac-sha2-256,hmac-sha2-512,hmac-sha1
    '';
    force = true;
  };
}
