# Pascal's plasma-manager configuration
{ ... }:
{
  imports = [ ../../shared/plasma-manager-base.nix ];

  custom.plasma = {
    enable = true;
    terminal = "ghostty";
    wallpaperResolution = "auto";
    keyboardLayout = "de";
    taskbarApps = [
      "applications:org.kde.dolphin.desktop"
      "applications:com.mitchellh.ghostty.desktop"
      "applications:outline-electron.desktop"
      "applications:firefox-nightly.desktop"
      "applications:io.github.tdesktop_x64.TDesktop.desktop"
      "applications:equibop.desktop"
      "applications:code.desktop"
      "applications:burpsuite.desktop"
      "applications:ghidra.desktop"
      "applications:re.rizin.cutter.desktop"
      "applications:org.wireshark.Wireshark.desktop"
    ];
    enablePowerdevilService = true;
    strictMode = true;
    autoLock = true;
    displayTimeouts = { turnOff = 900; dim = 600; };
    disableBlur = true;
    enableTripleBuffering = true;
    hideBrowserIntegrationReminder = true;
    # Akonadi events/tasks (Radicale via Merkuro) in the clock popup; plugin from kdepim-addons in tasks.nix
    calendarPlugins = [ "pimevents" ];
  };

  # Calendars shown by the PIM Events plugin. plasmashellrc is reset on every
  # generation (strictMode), so the GUI selection doesn't stick. Values are
  # Akonadi collection IDs of the Radicale DAV account: Todo, DEFAULT_TASK_CALENDAR_NAME,
  # Groceries, Calendar, Factor_. They change if the DAV account is re-added; list with:
  #   mariadb --socket=/run/user/1000/akonadi/mysql.socket akonadi -e "SELECT id, name FROM CollectionTable"
  programs.plasma.configFile.plasmashellrc.PIMEventsPlugin.calendars = "14,15,16,17,18";
}
