{ config, lib, pkgs, ... }:
{
    xdg.configFile."environment.d/ssh-agent.conf".text = ''
        SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
    '';
}
