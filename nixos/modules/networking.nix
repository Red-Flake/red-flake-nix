{ config
, lib
, pkgs
, ...
}:

{
  # Disable Avahi mDNS/DNS-SD (not needed for pentesting/gaming setup)
  # Reduces network broadcast footprint and silences "No NSS support for mDNS" warning
  services.avahi.enable = false;

  # NetworkManager
  networking.networkmanager = {
    enable = true;

    wifi = {
      backend = "iwd";
      powersave = false;
    };

    # IPv6 privacy extensions (RFC 4941): prefer rotating temporary addresses
    # as the source address. Note this is NOT "disable IPv6" — global addressing
    # and routing are unaffected either way; only source-address stability is.
    #
    # nixpkgs implements networking.tempAddresses via a udev RUN+= rule that
    # races interface creation, so it is applied inconsistently: on stellaris
    # wlan0 ended up with use_tempaddr=2 while eth0 got 0. NetworkManager
    # applies this at connection-activation time instead, so it is deterministic
    # and covers interfaces that appear after boot.
    #
    # Connections default to ip6-privacy=-1 ("use the sysctl"), so this sets the
    # global default for every NM-managed connection.
    # Verify:  cat /proc/sys/net/ipv6/conf/*/use_tempaddr
    settings.connection."ipv6.ip6-privacy" = 2;

    # Dynamically set NTP servers received via DHCP (systemd-timesyncd).
    # Debug: `sudo journalctl -u NetworkManager-dispatcher -e`
    dispatcherScripts = [
      {
        # Fix VPN split tunneling for lab VPNs (HackTheBox, OffSec, etc.)
        # Problem: When VPN is connected, some apps (Discord) send packets with the VPN
        # source IP (e.g., 192.168.45.171) out the regular interface (wlan0). The remote
        # server can't reply because that IP is unreachable from the internet.
        # Solution: Masquerade (SNAT) traffic from VPN IPs going out non-VPN interfaces.
        source = pkgs.writeShellScript "09-vpn-split-tunnel" ''
          export PATH="${lib.makeBinPath [ pkgs.iproute2 pkgs.iptables pkgs.gnugrep ]}:$PATH"

          INTERFACE="$1"
          ACTION="$2"

          # Only act on tun interfaces (OpenVPN)
          case "$INTERFACE" in
            tun*) ;;
            *) exit 0 ;;
          esac

          # Get the VPN interface's IP address
          VPN_IP=$(ip -4 addr show dev "$INTERFACE" | grep -oP 'inet \K[0-9.]+')

          case "$ACTION" in
            up)
              if [ -n "$VPN_IP" ]; then
                # Add masquerade rule: traffic from VPN IP going out non-tun interfaces
                # gets its source IP rewritten to the outgoing interface's IP
                iptables -t nat -C POSTROUTING -s "$VPN_IP" ! -o "$INTERFACE" -j MASQUERADE 2>/dev/null || \
                  iptables -t nat -A POSTROUTING -s "$VPN_IP" ! -o "$INTERFACE" -j MASQUERADE
                echo "VPN NAT enabled: masquerading traffic from $VPN_IP on non-VPN interfaces"
              fi
              ;;
            down)
              if [ -n "$VPN_IP" ]; then
                # Remove the masquerade rule when VPN disconnects
                iptables -t nat -D POSTROUTING -s "$VPN_IP" ! -o "$INTERFACE" -j MASQUERADE 2>/dev/null || true
                echo "VPN NAT disabled: removed masquerade rule for $VPN_IP"
              fi
              ;;
          esac
        '';
      }
      {
        source = pkgs.writeText "10-update-timesyncd" ''
          [ -z "$CONNECTION_UUID" ] && exit 0
          INTERFACE="$1"
          ACTION="$2"

          case "$ACTION" in
            up|dhcp4-change|dhcp6-change)
              systemctl restart systemd-timesyncd.service
              if [ -n "$DHCP4_NTP_SERVERS" ]; then
                echo "Will add the ntp server $DHCP4_NTP_SERVERS"
              else
                echo "No DHCP4 NTP available."
                exit 0
              fi

              mkdir -p /etc/systemd/timesyncd.conf.d
              echo "[Time]" > "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
              echo "NTP=$DHCP4_NTP_SERVERS" >> "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
              systemctl restart systemd-timesyncd.service
              ;;

            down)
              rm -f "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
              systemctl restart systemd-timesyncd.service
              ;;
          esac

          echo "Done!"
        '';
      }
    ];
  };

  # Let NetworkManager manage DHCP; avoid enabling dhcpcd (it can end up on the boot critical path).
  networking.useDHCP = lib.mkForce false;
  networking.dhcpcd.enable = lib.mkForce false;

  # Wi-Fi via iwd (used by NetworkManager when `networkmanager.wifi.backend = "iwd"`).
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network.EnableIPv6 = true;
      Settings.AutoConnect = true;
      DriverQuirks.PowerSaveDisable = "*";
    };
  };

  # Expose ports to the network (useful for smbserver/responder/http.server, etc.).
  networking.firewall.enable = false;
  networking.nftables.enable = false;

  # If dhcpcd is enabled elsewhere, avoid a full 1m30 shutdown delay if it hangs while stopping.
  systemd.services = lib.mkIf config.networking.dhcpcd.enable {
    dhcpcd.serviceConfig.TimeoutStopSec = "5s";
  };
}
