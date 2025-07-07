{ config, lib, pkgs, inputs, ... }:

let
  # Define the path to the profile picture file
  facePath = "${config.home.homeDirectory}/.face";
  
  # Define the Gravatar URL
  url = "https://2.gravatar.com/avatar/c891e0a6799055b534073decbd5254cd0552d9c748edff94bc7529b703047868?size=512&d=initials";
  
  # Define the curl command for reuse
  curlCmd = "${lib.getExe' pkgs.curl "curl"} -s -o ${facePath} ${url}";
in
{
  systemd.user.services.setprofilepicture = {
    Unit = {
      Description = "Download profile picture from Gravatar";
      After = [ "graphical-session.target" ];  # Ensure network is up
      Requires = [ "graphical-session.target" ];  # Network dependency
    };
    Install = {
      WantedBy = [ "default.target" ];  # Run at login
    };
    Service = {
      # Wait for internet connectivity before attempting download
      ExecStartPre = "-/bin/sh -c 'until ping -c 1 1.1.1.1 > /dev/null; do sleep 5; done'";
      
      # Download the profile picture if it doesn’t exist
      ExecStart = "-/bin/sh -c '[ ! -f ${facePath} ] && ${curlCmd}'";
      
      RestartSec = 10;  # Wait 10 seconds before retrying on failure
      Restart = "on-failure";  # Retry if it fails
      Type = "oneshot";  # Run once and exit
      RemainAfterExit = true;  # Stay 'active' after finishing
    };
  };
}