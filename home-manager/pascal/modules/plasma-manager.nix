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

  # Calendars shown by the PIM Events plugin (Digital Clock popup). plasmashellrc is
  # reset on every generation (strictMode), so the GUI selection doesn't stick.
  #
  # Values are Akonadi collection IDs of the Radicale DAV account: Todo,
  # DEFAULT_TASK_CALENDAR_NAME, Groceries, Calendar, Factor_. They survive reboots and
  # rebuilds, but change when the DAV account is removed/re-added in Merkuro, a calendar
  # is recreated on the server, or the Akonadi database is reset.
  #
  # Symptom: the clock shows no events and no calendars under
  # Digital Clock settings -> Calendar -> PIM Events, while Merkuro may still work.
  #
  # Diagnose:
  #   1. List the DAV collections Akonadi knows about:
  #        mariadb --socket=/run/user/1000/akonadi/mysql.socket akonadi -e "SELECT c.id, CAST(a.value AS CHAR) AS calendar FROM CollectionTable c JOIN ResourceTable r ON r.id = c.resourceId JOIN CollectionAttributeTable a ON a.collectionId = c.id AND a.type = 'ENTITYDISPLAY' WHERE r.name LIKE 'akonadi_dav%'"
  #   2. No calendars listed at all (only Contacts)? The DAV account lost its CalDAV URL.
  #      Merkuro -> Settings -> Accounts -> DAV account -> Remote URLs must contain both
  #      CalDAV and CardDAV for https://dav.netcat.rocks/ (check: grep remoteUrls
  #      ~/.config/akonadi_davgroupware_resource_*rc). Add CalDAV, then repeat step 1.
  #   3. Calendars listed but with other IDs than below? The IDs changed.
  #
  # Fix: put the current IDs below, `nixos-rebuild switch`, then
  # `systemctl --user restart plasma-plasmashell` (the plugin only reads this at startup).
  # Merkuro keeps its own selection by the same IDs (~/.config/merkuro.calendarrc,
  # [GlobalCollectionSelection]); after an ID change its sidebar comes up unticked and
  # the calendar looks empty. Re-tick the calendars there; that one isn't reset by Nix.
  programs.plasma.configFile.plasmashellrc.PIMEventsPlugin.calendars = "21,22,23,24,25";
}
