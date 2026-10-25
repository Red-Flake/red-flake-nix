_:

let
  browser = "firefox-nightly.desktop";
  terminal = "com.mitchellh.ghostty.desktop";
  fileManager = "org.kde.dolphin.desktop";
  editor = "code.desktop";
  imageViewer = "org.kde.gwenview.desktop";
  pdfViewer = "org.kde.okular.desktop";
in
{
  # Desktop settings dialogs replace mimeapps.list with their own copy; take
  # it back on every activation instead of failing on the collision.
  xdg.configFile."mimeapps.list".force = true;

  # Remmina (tray applet) and Equibop add their own autostart entries. Equibop
  # then starts in Wayland mode with speech dispatcher on and keeps producing
  # coredumps. An entry with the same name and Hidden=true turns them off
  # (XDG autostart spec), and the read-only link keeps the apps from
  # writing their own.
  xdg.configFile."autostart/remmina-applet.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Hidden=true
    '';
  };
  xdg.configFile."autostart/equibop.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Hidden=true
    '';
  };

  # NOTE: xdg.portal is configured at the NixOS level in nixos/modules/xdg.nix
  # Do NOT configure it here in home-manager to avoid duplicate portal configs

  # enable XDG mime
  xdg.mime = {
    enable = true;
  };

  # set default XDG mime applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # set default browser to firefox
      "text/html" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "application/xhtml+xml" = browser;
      "application/x-extension-xht" = browser;
      "application/x-extension-xhtml" = browser;
      "application/x-extension-shtml" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
      "x-scheme-handler/chrome" = browser;

      # set default terminal to Ghostty
      "application/x-gnome-terminal" = terminal;
      "application/x-terminal-emulator" = terminal;
      "application/x-terminator" = terminal;
      "application/x-uxterm" = terminal;
      "application/x-vte-terminal" = terminal;
      "application/x-xterm" = terminal;

      # set default file manager to dolphin
      "inode/directory" = fileManager;
      "application/x-gnome-saved-search" = fileManager;

      # fix issue with duplicate vscode icon due to url helper
      "x-scheme-handler/vscode" = editor;
    };
    associations = {
      added = {
        # set default browser
        "text/html" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/xhtml+xml" = browser;
        "application/xml" = browser;
        "application/x-extension-xht" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-shtml" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "x-scheme-handler/chrome" = browser;

        # set default terminal
        "application/x-gnome-terminal" = terminal;
        "application/x-terminal-emulator" = terminal;
        "application/x-terminator" = terminal;
        "application/x-uxterm" = terminal;
        "application/x-vte-terminal" = terminal;
        "application/x-xterm" = terminal;

        # set default file manager
        "inode/directory" = fileManager;
        "application/x-gnome-saved-search" = fileManager;

        # set default text editor to vscode
        "text/plain" = editor;
        "text/x-log" = editor;
        "text/x-c" = editor;
        "text/x-c++src" = editor;
        "text/x-chdr" = editor;
        "text/x-c++hdr" = editor;
        "text/x-c++-src" = editor;
        "text/x-cmake" = editor;
        "text/x-python" = editor;
        "text/x-shellscript" = editor;
        "text/x-rustsrc" = editor;
        "text/x-go" = editor;
        "text/x-java-source" = editor;
        "text/x-php" = editor;
        "text/x-javascript" = editor;
        "text/x-typescript" = editor;
        "text/x-markdown" = editor;
        "text/markdown" = editor;
        "application/json" = editor;
        "application/x-yaml" = editor;
        "application/x-toml" = editor;
        "application/x-httpd-php" = editor;
        "application/x-ruby" = editor;
        "application/x-perl" = editor;
        "application/x-lua" = editor;
        "application/x-sh" = editor;
        "application/x-bash" = editor;
        "application/x-zsh" = editor;
        "application/x-csh" = editor;
        "application/x-fish" = editor;
        "application/x-rust" = editor;
        "application/x-go" = editor;
        "application/x-java" = editor;
        "application/x-javascript" = editor;
        "application/x-typescript" = editor;
        "application/x-python-bytecode" = editor;
        "application/x-shellscript" = editor;
        "application/x-perl-script" = editor;
        "application/x-ruby-script" = editor;
        "application/x-lua-script" = editor;
        "application/x-cmake" = editor;
        "application/x-makefile" = editor;
        "text/x-makefile" = editor;

        # set default image viewer to gwenview
        "image/jpeg" = imageViewer;
        "image/png" = imageViewer;
        "image/gif" = imageViewer;
        "image/bmp" = imageViewer;
        "image/tiff" = imageViewer;
        "image/x-xcf" = imageViewer;
        "image/webp" = imageViewer;
        "image/svg+xml" = imageViewer;
        "image/x-icon" = imageViewer;
        "image/vnd.microsoft.icon" = imageViewer;
        "image/heif" = imageViewer;
        "image/heic" = imageViewer;

        # set default pdf viewer to okular
        "application/pdf" = pdfViewer;
      };
    };
  };
}
