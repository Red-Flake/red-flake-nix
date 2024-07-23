# responder-overlay.nix
final: prev:
{
  # FIX for responder: https://github.com/NixOS/nixpkgs/issues/255281#issuecomment-2244250577
  responder-patched = prev.responder.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs or [] ++ [ prev.openssl prev.coreutils ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/Responder
      cp -R . $out/share/Responder

      makeWrapper ${prev.python3.interpreter} $out/bin/responder \
        --set PYTHONPATH "$PYTHONPATH:$out/share/Responder" \
        --add-flags "$out/share/Responder/Responder.py" \
        --run "mkdir -p /var/lib/responder"

      substituteInPlace $out/share/Responder/Responder.conf \
        --replace-quiet "Responder-Session.log" "/var/lib/responder/Responder-Session.log" \
        --replace-quiet "Poisoners-Session.log" "/var/lib/responder/Poisoners-Session.log" \
        --replace-quiet "Analyzer-Session.log" "/var/lib/responder/Analyzer-Session.log" \
        --replace-quiet "Config-Responder.log" "/var/lib/responder/Config-Responder.log" \
        --replace-quiet "Responder.db" "/var/lib/responder/Responder.db"

      runHook postInstall

      runHook postPatch
    '';

    postInstall = ''
      wrapProgram $out/bin/responder \
        --run "mkdir -p /var/lib/responder/certs && ${prev.openssl}/bin/openssl genrsa -out /var/lib/responder/certs/responder.key 2048 && ${prev.openssl}/bin/openssl req -new -x509 -days 3650 -key /var/lib/responder/certs/responder.key -out /var/lib/responder/certs/responder.crt -subj '/'" \
        --run "mkdir -p /etc/responder && if [ ! -f /etc/responder/Responder.conf ]; then cp $out/share/Responder/Responder.conf /etc/responder/Responder.conf && chmod +w /etc/responder/Responder.conf; fi"
    '';

    postPatch = ''
      if [ -f $out/share/Responder/settings.py ]; then
        substituteInPlace $out/share/Responder/settings.py \
          --replace-quiet "self.LogDir = os.path.join(self.ResponderPATH, 'logs')" "self.LogDir = os.path.join('/var/lib/responder', 'logs')" \
          --replace-quiet "os.path.join(self.ResponderPATH, 'Responder.conf')" "'/etc/responder/Responder.conf'"
      fi

      if [ -f $out/share/Responder/utils.py ]; then
        substituteInPlace $out/share/Responder/utils.py \
          --replace-quiet "logfile = os.path.join(settings.Config.ResponderPATH, 'logs', fname)" "logfile = os.path.join('/var/lib/responder', 'logs', fname)"
      fi

      if [ -f $out/share/Responder/Responder.py ]; then
        substituteInPlace $out/share/Responder/Responder.py \
          --replace-quiet "certs/responder.crt" "/var/lib/responder/certs/responder.crt" \
          --replace-quiet "certs/responder.key" "/var/lib/responder/certs/responder.key"
      fi

      if [ -f $out/share/Responder/Responder.conf ]; then
        substituteInPlace $out/share/Responder/Responder.conf \
          --replace-quiet "certs/responder.crt" "/var/lib/responder/certs/responder.crt" \
          --replace-quiet "certs/responder.key" "/var/lib/responder/certs/responder.key"
      fi
    '';
  });
}
