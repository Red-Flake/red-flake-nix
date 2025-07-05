{ config, lib, pkgs, inputs, ... }:

{
  systemd.user.services.setprofilepicture = {
    Unit = {
      Description = "Download profile picture from Gravatar";
      After = [ "network-online.target" ];  # Ensure network is available before running
      Requires = [ "network-online.target" ];  # Ensure dependency
    };
    Install = {
      WantedBy = [ "default.target" ];  # Run on user login
    };
    Service = {
      ExecStart = ''
        if [ ! -f ${config.home.homeDirectory}/.face ]; then
          ${lib.getExe' pkgs.curl "curl"} -s -o ${config.home.homeDirectory}/.face https://2.gravatar.com/avatar/c891e0a6799055b534073decbd5254cd0552d9c748edff94bc7529b703047868?size=512&d=initials
        fi
      '';
      ExecStartPost = ''
        if [ ! -f ${config.home.homeDirectory}/.face ]; then
          echo "Profile picture download failed, retrying in 30 seconds..."
          sleep 30
          ${lib.getExe' pkgs.curl "curl"} -s -o ${config.home.homeDirectory}/.face https://2.gravatar.com/avatar/c891e0a6799055b534073decbd5254cd0552d9c748edff94bc7529b703047868?size=512&d=initials
        fi
      '';
      RestartSec = 10;
      Restart = "on-failure";  # Retry if it fails
      Type = "oneshot";  # Ensures the service runs once and exits
      RemainAfterExit = true;  # Keep the service status as 'active' after it finishes
    };
  };
}
