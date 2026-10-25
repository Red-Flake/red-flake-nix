{ pkgsUnstable, pkgs, ... }:
let
  msfdb = "${pkgsUnstable.metasploit}/bin/msfdb";
in
{
  # Systemd user service to auto-start msfdb
  # msfdb manages its own embedded PostgreSQL on port 5433
  # Uses system PostgreSQL from /run/current-system/sw/bin to ensure version consistency
  systemd.user.services.msfdb = {
    Unit = {
      Description = "Metasploit PostgreSQL Database";
      After = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "PATH=/run/current-system/sw/bin";
      # Initialize the database on first start
      ExecStartPre = "${pkgs.writeShellScript "msfdb-init" ''
        if [ ! -d "$HOME/.msf4/db" ]; then
          ${msfdb} init --use-defaults
        fi
      ''}";
      ExecStart = "${msfdb} start";
      ExecStop = "${msfdb} stop";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
