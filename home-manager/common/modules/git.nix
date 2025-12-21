# Parameterized git configuration
{ config
, lib
, gitConfig ? null
, ...
}:
let
  # Default git config if none provided
  defaultConfig = {
    userName = "Default User";
    userEmail = "user@example.com";
    signing = null;
  };

  finalConfig = if gitConfig != null then gitConfig else defaultConfig;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    # Conditional signing configuration
    signing = lib.mkIf (finalConfig.signing != null) {
      key =
        if lib.isString finalConfig.signing.key then
          finalConfig.signing.key
        else
          "${config.home.homeDirectory}/.ssh/id_rsa.pub";
      signByDefault = finalConfig.signing.signByDefault or true;
      format = finalConfig.signing.format or "ssh";
    };

    settings = {
      user = {
        email = finalConfig.userEmail;
        name = finalConfig.userName;
      };

      pull.rebase = true;
      push.autoSetupRemote = true;
    }
    // lib.optionalAttrs (finalConfig.signing != null) {
      gpg.format = finalConfig.signing.format or "ssh";
    };
  };
}
