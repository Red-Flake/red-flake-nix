# Shanzem's plasma-manager configuration
{ ... }:
{
  imports = [ ../../shared/plasma-manager-base.nix ];

  custom.plasma = {
    enable = true;
    terminal = "ghostty";
    wallpaperResolution = "auto";
    keyboardLayout = "gb";
    taskbarApps = [
      "applications:org.kde.dolphin.desktop"
      "applications:com.mitchellh.ghostty.desktop"
      "applications:firefox.desktop"
      "applications:obsidian.desktop"
      "applications:google-chrome.desktop"
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
