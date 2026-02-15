{ lib
, pkgs
, ...
}:

{
  home.activation.flatpak = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    flatpak="${lib.getExe' pkgs.flatpak "flatpak"}"
    getent="${lib.getExe' pkgs.glibc.bin "getent"}"
    grep="${lib.getExe' pkgs.gnugrep "grep"}"
    timeout="${lib.getExe' pkgs.coreutils "timeout"}"

    # Don't rely on `ping` here (ICMP can be blocked and it may not be available
    # in the activation environment). If Flathub isn't present yet, do a quick
    # DNS-only check and then attempt to add the remote with a short timeout.
    if ! "$flatpak" remote-list --user --columns=name 2>/dev/null | "$grep" -qx flathub; then
      if "$timeout" 2s "$getent" hosts dl.flathub.org >/dev/null 2>&1; then
        "$timeout" 20s "$flatpak" remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
      fi
    fi
  '';
}
