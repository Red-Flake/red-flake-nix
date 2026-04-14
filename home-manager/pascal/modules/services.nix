_:
{
  services = {
    kdeconnect.enable = true; # enable KDE Connect
    ssh-agent.enable = true; # enable SSH Agent
    udiskie.enable = true; # Automount - make sure your user is in the disk group
  };

  # Fix KDE Connect "Failed to send mDNS query" errors at startup
  # KDE Connect starts before network is fully configured; delay its start
  systemd.user.services.kdeconnect = {
    Unit = {
      After = [ "graphical-session.target" "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      # Add a small delay to ensure network interfaces have IP addresses assigned
      ExecStartPre = "/run/current-system/sw/bin/sleep 5";
    };
  };

  # Suppress harmless but noisy Ghostty log messages in journald
  # (gtk-xft-dpi warnings, GtkGizmo min width/height, cgroup info, etc.)
  systemd.user.services.app-com-mitchellh-ghostty = {
    Service = {
      LogFilterPatterns = [
        "~gtk-xft-dpi"
        "~GtkGizmo"
        "~transient scope created"
        "~cgroup isolation enabled"
      ];
    };
  };

  # Fix drkonqi-coredump-pickup.service - restore the full service definition
  # Home-manager's systemd.user.services creates a *replacement* file, not a drop-in.
  # The original drkonqi package service was being replaced with one missing ExecStart.
  # We must include all required fields from the original service.
  systemd.user.services.drkonqi-coredump-pickup = {
    Unit = {
      Description = "Consume pending crashes using DrKonqi";
      PartOf = [ "graphical-session.target" ];
      Requires = [ "drkonqi-coredump-launcher.socket" ];
      After = [ "plasma-core.target" "drkonqi-coredump-launcher.socket" ];
      ConditionUser = "!@system";
    };
    Service = {
      ExecStart = "/run/current-system/sw/libexec/drkonqi-coredump-processor --settle-first --pickup --uid %U";
      RuntimeMaxSec = "30min";
    };
    Install = {
      WantedBy = [ "plasma-core.target" ];
    };
  };

  # =============================================================================
  # Disabled services - to re-enable, remove or comment out the corresponding block
  # =============================================================================

  # KDE Discover notifier: Shows software update notifications in system tray
  # Used by: Notifying about available package/flatpak updates
  # Re-enable if: You want automatic update notifications
  xdg.configFile."autostart/org.kde.discover.notifier.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # Geoclue agent: Provides location services (GPS/WiFi-based geolocation)
  # Used by: Weather widgets, Maps, location-aware apps
  # Re-enable if: Apps can't detect your location or weather widgets show wrong location
  xdg.configFile."autostart/geoclue-demo-agent.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # Plasma KAccess: KDE accessibility features (sticky keys, slow keys, bounce keys)
  # Used by: Accessibility keyboard features, visual bell, screen reader integration
  # Re-enable if: Accessibility keyboard shortcuts or features stop working
  xdg.configFile."autostart/kaccess.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # AT-SPI D-Bus bus: Accessibility services bus for screen readers, magnifiers, etc.
  # Used by: Orca screen reader, accessibility tools, some automation tools
  # Re-enable if: Screen reader stops working or accessibility features break
  # Note: This is started via dbus activation, disabling autostart may not fully stop it
  xdg.configFile."autostart/at-spi-dbus-bus.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  # Note on OBEX (Bluetooth file transfer):
  # obex.service is socket-activated by bluetooth when a file transfer is initiated.
  # It cannot be fully disabled via autostart - it will start on-demand when needed.
  # This is fine as it only runs during active Bluetooth file transfers.

  # =============================================================================
  # Disable AT-SPI accessibility bus via environment variable
  # =============================================================================
  # This tells GTK/Qt apps to skip AT-SPI entirely rather than waiting for a connection.
  # Using env vars is the correct approach - masking the systemd service breaks D-Bus
  # activation and causes apps to hang waiting for timeouts.
  home.sessionVariables = {
    NO_AT_BRIDGE = "1"; # Disable AT-SPI bridge (GTK2/GTK3)
    GTK_A11Y = "none"; # Disable GTK4 accessibility
  };
}
