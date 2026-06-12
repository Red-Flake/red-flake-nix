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
      "applications:burpsuitepro.desktop"
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
  };
}
