# Activity tracking on the desktop (KDE Plasma and Hyprland, both Wayland):
#  - ActivityWatch server + awatcher (active window and AFK; KWin script on Plasma,
#    wlr protocols on Hyprland). Web UI: http://localhost:5600
#  - break-reminder: reminds after N active minutes without a real break
#  - productivity-today: active and work time of the day (04:00 to 04:00), as a
#    command and as an evening notification, logged to ~/.local/share/productivity/log.csv
#
# Check after a rebuild:
#   systemctl --user status activitywatch activitywatch-watcher-awatcher break-reminder
#   systemctl --user list-timers productivity-today
# Test the reminder without waiting 90 min:
#   systemctl --user stop break-reminder
#   ACTIVE_MINUTES=2 break-reminder    # shows within a minute if you were active 2 min, then Ctrl+C
#   systemctl --user start break-reminder
{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.custom.productivity;

  awUrl = "http://127.0.0.1:5600";
  notifySend = lib.getExe' pkgs.libnotify "notify-send";

  breakReminder = pkgs.writeShellScriptBin "break-reminder" ''
    export AW_URL=${awUrl} NOTIFY_SEND=${notifySend} GDBUS=${pkgs.glib.bin}/bin/gdbus
    exec ${pkgs.python3.interpreter} -I ${./break-reminder.py} "$@"
  '';

  # The work patterns are baked in, so the command and the timer report the same.
  regex = patterns: lib.escapeShellArg (lib.concatStringsSep "|" patterns);
  productivityToday = pkgs.writeShellScriptBin "productivity-today" ''
    export AW_URL=${awUrl} NOTIFY_SEND=${notifySend}
    export WORK_APPS=${regex cfg.workApps} WORK_TITLES=${regex cfg.workTitles}
    exec ${pkgs.python3.interpreter} -I ${./productivity-today.py} "$@"
  '';

  session = {
    After = [ "graphical-session.target" ];
    PartOf = [ "graphical-session.target" ];
  };
in
{
  options.custom.productivity = {
    activeMinutes = lib.mkOption {
      type = lib.types.int;
      default = 90;
      description = "Active minutes without a real break until the break reminder.";
    };
    breakMinutes = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Minutes without input that count as a real break and reset the count.";
    };
    repeatMinutes = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "Repeat the reminder this often until a break happens.";
    };
    snoozeMinutes = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Delay after clicking \"Later\"; longer than repeatMinutes, or snoozing changes nothing.";
    };
    criticalMinutes = lib.mkOption {
      type = lib.types.int;
      default = 120;
      description = "From this many active minutes the reminder is critical and stays on screen.";
    };
    idleTimeoutSeconds = lib.mkOption {
      type = lib.types.int;
      default = 180;
      description = "awatcher: seconds without input until the user counts as AFK.";
    };
    summaryTime = lib.mkOption {
      type = lib.types.str;
      default = "23:20";
      description = "Time of the daily summary notification.";
    };
    workApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Terminals; they also cover every CLI tool (nmap, netexec, msfconsole, ...).
        "ghostty"
        "konsole"
        # Editors
        "^code$"
        "org.kde.kate"
        "org.kde.kwrite"
        "gvim"
        # Web
        "burp"
        "zaproxy"
        # Reverse engineering
        "ghidra"
        "cutter"
        "jadx"
        "ilspy"
        "binaryninja"
        "ghex"
        "ollydbg"
        "^edb$"
        # Network and AD
        "wireshark"
        "bloodhound"
        "krdc"
        "filezilla"
        # Databases
        "dbeaver"
        "sqlitebrowser"
        # Notes, reports and course PDFs
        "outline"
        "okular"
        "libreoffice"
        "onlyoffice"
        "^(tm|pm|pr)$" # FreeOffice TextMaker, PlanMaker, Presentations
      ];
      description = "Case-insensitive regexes on the app id (KWin resource class) that count as work.";
    };
    workTitles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Mostly browser tabs.
        "Visual Studio Code"
        "Hack ?The ?Box"
        "Proving Grounds"
        "OffSec"
        "TryHackMe"
        "PortSwigger"
        "HackTricks"
        "PayloadsAllTheThings"
        "GTFOBins"
        "LOLBAS"
        "Exploit-DB"
        "Exploit Database"
        "CyberChef"
        "Reverse Shell Generator"
        "BloodHound"
        "IppSec"
        "0xdf"
        "GitHub"
        "Stack Overflow"
        "NixOS"
        "Home Manager"
        "beacon"
      ];
      description = "Case-insensitive regexes on the window title that count as work.";
    };
  };

  config = {
    home.packages = [ breakReminder productivityToday ];

    services.activitywatch = {
      enable = true;
      package = pkgs.aw-server-rust;
      watchers.awatcher.package = pkgs.awatcher;
    };

    # awatcher reads its own config file, not the one under activitywatch/.
    xdg.configFile."awatcher/config.toml".text = ''
      [server]
      host = "127.0.0.1"
      port = 5600

      [awatcher]
      idle-timeout-seconds = ${toString cfg.idleTimeoutSeconds}
      poll-time-idle-seconds = 4
      poll-time-window-seconds = 1
    '';

    # Home Manager starts watchers with default.target, before Wayland is up, and
    # never restarts them. Start awatcher with the graphical session instead.
    systemd.user.services.activitywatch-watcher-awatcher = {
      Unit = session;
      Service = {
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
    };

    systemd.user.services.break-reminder = {
      Unit = session // {
        Description = "Break reminder after active work";
        After = session.After ++ [ "activitywatch.service" ];
      };
      Service = {
        ExecStart = lib.getExe breakReminder;
        Restart = "on-failure";
        RestartSec = 30;
        Environment = [
          "ACTIVE_MINUTES=${toString cfg.activeMinutes}"
          "BREAK_MINUTES=${toString cfg.breakMinutes}"
          "REPEAT_MINUTES=${toString cfg.repeatMinutes}"
          "SNOOZE_MINUTES=${toString cfg.snoozeMinutes}"
          "CRITICAL_MINUTES=${toString cfg.criticalMinutes}"
        ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.productivity-today = {
      Unit.Description = "Daily summary of active and work time";
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe productivityToday} --notify";
      };
    };

    # Not Persistent: a catch-up run in the morning would report the new, empty day.
    # The previous day still gets logged completely on the next run.
    systemd.user.timers.productivity-today = {
      Unit.Description = "Daily summary of active and work time";
      Timer.OnCalendar = "*-*-* ${cfg.summaryTime}:00";
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
