{ ...
}:
{
  services = {
    kdeconnect.enable = true; # enable KDE Connect
    ssh-agent.enable = true; # enable SSH Agent
    udiskie.enable = true; # Automount - make sure your user is in the disk group
  };
}
