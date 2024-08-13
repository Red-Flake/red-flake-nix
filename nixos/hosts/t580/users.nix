{ 
  config,
  lib,
  pkgs,
  modulesPath,
  user,
  ... 
}: {
# Configure your system-wide user settings (groups, etc), add more users as needed.
  users = {
    mutableUsers = false;
    # setup users with persistent passwords
    # https://reddit.com/r/NixOS/comments/o1er2p/tmpfs_as_root_but_without_hardcoding_your/h22f1b9/
    # create a password with for root and $user with:
    # mkpasswd -m sha-512 'PASSWORD' | sudo tee -a /persist/etc/shadow/root
    users.${user} = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      #initialPassword = "correcthorsebatterystaple";
      # set password file
      passwordFile = "/etc/shadow/${user}";
      # set normal user
      isNormalUser = true;
      # set shell for user
      shell = pkgs.zsh;
      # set ssh authorized_keys
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [
        "wheel"
        "sudo"
        "uucp"
        "lp"
        "adm"
        "input"
        "uinput"
        "docker"
        "lxd"
        "libvirtd"
        "vboxsf"
        "vboxusers"
        "wireshark"
        "networkmanager"
        "network"
        "audio"
        "storage"
      ];
    };
  };
}
