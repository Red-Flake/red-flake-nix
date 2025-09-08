{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    genericName = "File Manager";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo %u";
    icon = "nemo";
    type = "Application";
    categories = [
      "GNOME"
      "GTK"
      "Utility"
      "Core"
      "FileManager"
    ];
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "nemo.desktop" ];
      "application/x-gnome-saved-search" = [ "nemo.desktop" ];
    };
  };
  dconf = {
    settings = {
      # set default terminal for nemo to konsole
      "org/cinnamon/desktop/applications/terminal" = {
        exec = "konsole";
        # exec-arg = ""; # argument
      };
    };
  };
}
