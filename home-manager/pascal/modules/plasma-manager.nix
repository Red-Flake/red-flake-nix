# Pascal's plasma-manager configuration
{ lib, ... }:
let
  # Akonadi collection IDs of the Radicale DAV account. How to look them up is
  # described at the calendar settings below.
  calendarIds = {
    todo = 21;
    defaultTask = 22; # DEFAULT_TASK_CALENDAR_NAME
    groceries = 23;
    calendar = 24;
    factor = 25; # Factor_
  };

  # Calendars shown in the Plasma clock and ticked in Merkuro.
  shownCalendars = with calendarIds; [ todo defaultTask calendar factor ];
in
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

  # Calendars shown by the PIM Events plugin (Digital Clock popup) and ticked in
  # Merkuro's sidebar, both from shownCalendars above. strictMode writes these keys on
  # every generation and makes them immutable, so a selection made in the GUI doesn't
  # stick; change shownCalendars instead.
  #
  # The values are the Akonadi collection IDs in calendarIds above. They survive
  # reboots and rebuilds, but change when the DAV account is removed/re-added in
  # Merkuro, a calendar is recreated on the server, or the Akonadi database is reset.
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
  #   3. Calendars listed but with other IDs than in calendarIds? The IDs changed.
  #
  # Fix: put the current IDs into calendarIds, `nixos-rebuild switch`, then
  # `systemctl --user restart plasma-plasmashell` (the plugin only reads this at startup)
  # and restart Merkuro.
  programs.plasma.configFile.plasmashellrc.PIMEventsPlugin.calendars =
    lib.concatMapStringsSep "," toString shownCalendars;

  # Merkuro stores its sidebar selection as "c<ID>" in [GlobalCollectionSelection].
  # Only this key is managed; the rest of merkuro.calendarrc is left alone.
  programs.plasma.configFile."merkuro.calendarrc".GlobalCollectionSelection.Selection =
    lib.concatMapStringsSep "," (id: "c${toString id}") shownCalendars;
}
