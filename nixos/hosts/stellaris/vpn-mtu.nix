# Auto-lower MTU on VPN tunnel interfaces to 1280.
#
# Why: home WAN ~1460 (likely DS-Lite), and lab providers' transit paths drop
# ICMP frag-needed packets — so large packets vanish silently while control
# packets succeed. Symptom: FTP/SMB/HTTP hang at 0 B/s after connect.
# MTU 1280 = IPv6 minimum, safe everywhere, ~10% throughput cost.
#
# Detection is by kernel-reported interface kind (info_kind), not name, so it
# catches WireGuard regardless of naming scheme (wg0, ronin66-sa, nm-wg-xyz)
# and OpenVPN tun/tap regardless of which tunN slot was assigned.
{ pkgs, ... }:
{
  systemd.services.vpn-mtu-watcher = {
    description = "Auto-lower MTU to 1280 on WireGuard/OpenVPN tunnel interfaces";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    path = with pkgs; [
      iproute2
      jq
      coreutils
      gnugrep
      gnused
    ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "5s";

      # Minimal privileges: only CAP_NET_ADMIN to change MTU
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };

    script = ''
      set -u
      TARGET_MTU=1280

      is_vpn_iface() {
        local iface="$1" json kind flags ltype
        json=$(ip -d -j link show dev "$iface" 2>/dev/null) || return 1
        [ -z "$json" ] && return 1

        # Primary: match by kernel-reported kind.
        kind=$(printf '%s' "$json" | jq -r '.[0].linkinfo.info_kind // empty')
        case "$kind" in
          wireguard|tun|tap|openvpn) return 0 ;;
        esac

        # Fallback: link_type=none + POINTOPOINT + NOARP = software tunnel.
        ltype=$(printf '%s' "$json" | jq -r '.[0].link_type // empty')
        flags=$(printf '%s' "$json" | jq -r '.[0].flags // [] | join(",")')
        if [ "$ltype" = "none" ] \
           && printf '%s' "$flags" | grep -q 'POINTOPOINT' \
           && printf '%s' "$flags" | grep -q 'NOARP'; then
          return 0
        fi

        return 1
      }

      fix_iface() {
        local iface="$1" mtu kind
        [ -z "$iface" ] && return 0
        [ ! -e "/sys/class/net/$iface" ] && return 0
        is_vpn_iface "$iface" || return 0

        mtu=$(cat "/sys/class/net/$iface/mtu" 2>/dev/null || echo 0)
        if [ "$mtu" -gt "$TARGET_MTU" ]; then
          if ip link set dev "$iface" mtu "$TARGET_MTU" 2>/dev/null; then
            kind=$(ip -d -j link show dev "$iface" 2>/dev/null \
                   | jq -r '.[0].linkinfo.info_kind // "fallback"')
            echo "vpn-mtu-watcher: lowered $iface MTU $mtu -> $TARGET_MTU (kind: $kind)"
          fi
        fi
      }

      # Initial pass: fix any VPN interfaces already up at service start
      for p in /sys/class/net/*; do
        fix_iface "$(basename "$p")"
      done

      # Watch for link events and re-check matched interfaces
      ip monitor link | while IFS= read -r line; do
        iface=$(printf '%s\n' "$line" | sed -nE 's/^[0-9]+:[[:space:]]+([^:@[:space:]]+).*/\1/p')
        fix_iface "$iface"
      done
    '';
  };
}
