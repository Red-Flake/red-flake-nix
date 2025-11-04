{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  networking.wireless.iwd.enable = true;
  networking.interfaces.wlan0.useDHCP = true;
  networking.wireless.interfaces = [ "wlan0" ];
  networking.wireless.iwd.settings = {
    IPv6 = {
      Enabled = true;
    };
    Settings = {
      AutoConnect = true;
    };
    General = {
      PowerSave = false;
    };
  };
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.wifi.powersave = false;

  networking.firewall.enable = false; # This one is necessary to expose ports to the netwok. Usefull for smbserver, responder, http.server, ...
  networking.nftables.enable = false; # This one is necessary to expose ports to the netwok. Usefull for smbserver, responder, http.server, ...

  ## To use, put this in your configuration, switch to it, and restart NM:
  ## $ sudo systemctl restart NetworkManager.service
  ## To check if it works, you can do `sudo systemctl status systemd-timesyncd.service`
  ## (it may take a bit of time to pick the right NTP as it may try the
  ## other NTP firsts)
  networking.networkmanager.dispatcherScripts = [
    {
      # https://wiki.archlinux.org/title/NetworkManager#Dynamically_set_NTP_servers_received_via_DHCP_with_systemd-timesyncd
      # You can debug with sudo journalctl -u NetworkManager-dispatcher -e
      # make sure to restart NM as described above
      source = pkgs.writeText "10-update-timesyncd" ''
        [ -z "$CONNECTION_UUID" ] && exit 0
        INTERFACE="$1"
        ACTION="$2"
        case $ACTION in
        up | dhcp4-change | dhcp6-change)
            systemctl restart systemd-timesyncd.service
            if [ -n "$DHCP4_NTP_SERVERS" ]; then
              echo "Will add the ntp server $DHCP4_NTP_SERVERS"
            else
              echo "No DHCP4 NTP available."
              exit 0
            fi
            mkdir -p /etc/systemd/timesyncd.conf.d
            # <<-EOF must really use tabs to keep indentation correct… and tabs are often converted to space in wiki
            # so I don't want to risk strange issues with indentation
            echo "[Time]" > "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
            echo "NTP=$DHCP4_NTP_SERVERS" >> "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
            systemctl restart systemd-timesyncd.service
            ;;
        down)
            rm -f "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
            systemctl restart systemd-timesyncd.service
            ;;
        esac
        echo 'Done!'
      '';
    }
  ];
}
