{ config
, ...
}:
{
  # NixOS does not manage /etc/hosts here (see tweaks.nix), so it stays
  # editable. Seed it with the defaults only when it does not exist yet;
  # tmpfiles "f" never touches the content of an existing file.
  systemd.tmpfiles.settings."10-etc-hosts"."/etc/hosts".f = {
    mode = "0644";
    user = "root";
    group = "root";
    argument = ''
      127.0.0.1 localhost
      ::1       localhost
      127.0.0.2 ${config.networking.hostName}
      ::1       ${config.networking.hostName}
    '';
  };
}
