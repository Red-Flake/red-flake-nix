{ config, lib, pkgs, ... }:

let
  revSSHkey = builtins.readFile ./ssh/id_reverse-ssh;
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
      After = [ "default.target" ];  # Ensure the user session is ready before running
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${scriptWriteRevSSHKey}";
      ExecStartPost = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chmod 600 %h/.ssh/id_reverse-ssh' || true
      '';
      Type = "oneshot";  # Ensures the service runs once and exits
      RemainAfterExit = true;  # Keep the service status as 'active' after it finishes
    };
  };

  # Set ~/.ssh/config for reverse-ssh
  home.file.".ssh/config" = {
    text = ''
      Host target
          Hostname 127.0.0.1
          Port 8888
          IdentityFile ~/.ssh/id_reverse-ssh
          IdentitiesOnly yes
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
    '';
    force = true;
  };

}
