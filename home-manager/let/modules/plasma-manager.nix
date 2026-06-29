# Let's plasma-manager configuration
{ ... }:
{
  imports = [ ../../shared/plasma-manager-base.nix ];

  custom.plasma = {
    enable = true;
    terminal = "konsole";
    wallpaperResolution = "1080p";
    keyboardLayout = "de";
    taskbarApps = [
      "applications:org.kde.dolphin.desktop"
      "applications:org.kde.konsole.desktop"
      "applications:firefox-nightly.desktop"
      "applications:org.telegram.desktop.desktop"
      "applications:code.desktop"
      "applications:burpsuite.desktop"
      "applications:ghidra.desktop"
      "applications:org.wireshark.Wireshark.desktop"
    ];
    enablePowerdevilService = false;
    strictMode = false;
    autoLock = false;
    displayTimeouts = { turnOff = 600000; dim = 600000; };
    disableBlur = false;
    enableTripleBuffering = false;
    hideBrowserIntegrationReminder = false;
  };
}
