{ 
  config,
  lib,
  user,
  ... 
}: let
  userShadowFile = "/persist/etc/shadow.d/${user}";
  rootShadowFile = "/persist/etc/shadow.d/root";
  rootMountPoint = if builtins.pathExists "/mnt" then "/mnt" else "";
  userShadowFileFull = "${rootMountPoint}${userShadowFile}";
  rootShadowFileFull = "${rootMountPoint}${rootShadowFile}";
in
{
  # Silence warning about setting multiple user password options
  # https://github.com/NixOS/nixpkgs/pull/287506#issuecomment-1950958990
  options = {
    warnings = lib.mkOption {
      apply = lib.filter (
        w: !(lib.strings.hasInfix "The options silently discard others by the order of precedence" w)
      );
    };
  };

  config = lib.mkMerge [
    {
      users = {
        mutableUsers = false;

        # setup users with persistent passwords
        # https://reddit.com/r/NixOS/comments/o1er2p/tmpfs_as_root_but_without_hardcoding_your/h22f1b9/
        # create a password with for root and $user with:
        # mkpasswd -m sha-512 'PASSWORD' | sudo tee -a /persist/etc/shadow.d/root
        users = {
          root = lib.mkMerge [
            {
              isNormalUser = false;
            }
            (lib.mkIf (builtins.pathExists rootShadowFileFull) {
              hashedPasswordFile = rootShadowFile;
            })
            (lib.mkIf (!(builtins.pathExists rootShadowFileFull)) {
              password = "password";
            })
          ];

          ${user} = lib.mkMerge [
            {
              isNormalUser = true;
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
                "video"
                "render"
              ];
            }
            (lib.mkIf (builtins.pathExists userShadowFileFull) {
              hashedPasswordFile = userShadowFile;
            })
            (lib.mkIf (!(builtins.pathExists userShadowFileFull)) {
              password = "password";
            })
          ];
        };
      };
    }

    ## Optionally later you can re-enable sops safely without conflict
    # disable sops for now
    # use sops for user passwords if enabled
    #(lib.mkIf config.custom.sops.enable (
    #  let
    #    inherit (config.sops) secrets;
    #  in
    #  {
    #    sops.secrets = {
    #      rp.neededForUsers = true;
    #      up.neededForUsers = true;
    #    };
    #    users.users = {
    #      root.hashedPasswordFile = lib.mkForce secrets.rp.path;
    #      ${user}.hashedPasswordFile = lib.mkForce secrets.up.path;
    #    };
    #  }
    #))

  ];
}
