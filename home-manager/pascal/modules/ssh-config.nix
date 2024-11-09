{ config, lib, pkgs, ... }:
{
    home.file.".ssh/config".text = ''
        Host target
                Hostname 127.0.0.1
                Port 8888
                IdentityFile ~/.ssh/id_reverse-ssh
                IdentitiesOnly yes
                StrictHostKeyChecking no
                UserKnownHostsFile /dev/nulls
    '';
}