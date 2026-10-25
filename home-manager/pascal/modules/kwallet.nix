{ config
, ...
}:

let
  kwalletrcPath = "${config.xdg.configHome}/kwalletrc";
  sourceKwalletrcPath = "${./kwallet/kwalletrc}";
in
{
  # KWallet writes to kwalletrc, so seed a writable copy only when it is
  # missing and leave later changes alone.
  systemd.user.tmpfiles.rules = [
    "C ${kwalletrcPath} 0644 - - - ${sourceKwalletrcPath}"
  ];
}
