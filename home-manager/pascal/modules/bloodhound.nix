{ config
, ...
}:

let
  bloodhoundPath = "${config.xdg.configHome}/bloodhound";
  configJsonPath = "${config.xdg.configHome}/bloodhound/config.json";
  sourceConfigJsonPath = "${./bloodhound/config.json}";
in
{
  # BloodHound writes to config.json at runtime, so it can't be a store link.
  # Replace it with a fresh writable copy at every login (and on switch when
  # the rules change): "r" removes the old file, "C" copies the new one.
  systemd.user.tmpfiles.rules = [
    "d ${bloodhoundPath} 0755 - - -"
    "r ${configJsonPath}"
    "C ${configJsonPath} 0644 - - - ${sourceConfigJsonPath}"
  ];

  xdg.desktopEntries.bloodhound = {
    name = "BloodHound";
    genericName = "Six Degrees of Domain Admin";
    exec = ''
      env XCURSOR_SIZE=36 BloodHound --no-sandbox --ozone-platform=wayland --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations %U
    '';
    icon = "${config.home.homeDirectory}/.local/share/icons/red-flake/bloodhound.svg";
    terminal = false;
    type = "Application";
    categories = [
      "X-Post-Exploitation"
    ];
    startupNotify = true;
    settings = {
      StartupWMClass = "BloodHound";
    };
  };
}
