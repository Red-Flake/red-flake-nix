_:

{
  # TPM2 Settings
  # Enable TPM2 Module
  security.tpm2.enable = true;

  # sudo settings
  security.sudo = {
    extraConfig = "Defaults lecture=never\nDefaults passwd_timeout=0\nDefaults insults";
  };

  # Polkit rules
  security.polkit.extraConfig = ''
    // Allow wheel users to suspend/hibernate without password
    // Workaround for SDDM Wayland not properly releasing seat on login
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.login1.suspend" ||
           action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
           action.id == "org.freedesktop.login1.hibernate" ||
           action.id == "org.freedesktop.login1.hibernate-multiple-sessions" ||
           action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
           action.id == "org.freedesktop.login1.reboot" ||
           action.id == "org.freedesktop.login1.reboot-multiple-sessions") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });

    // gamemode helpers need no rule here: gamemode ships its own polkit rule
    // for members of the gamemode group (com.feralinteractive.GameMode.*).
  '';

}
