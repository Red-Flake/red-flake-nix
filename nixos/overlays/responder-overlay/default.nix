# responder-overlay.nix
final: prev:
{
  # FIX for responder: https://github.com/NixOS/nixpkgs/issues/255281#issuecomment-2229259710
  responder-patched = prev.responder.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs or [] ++ [ prev.openssl prev.coreutils ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share $out/share/Responder
      cp -R . $out/share/Responder

      makeWrapper ${prev.python3.interpreter} $out/bin/responder \
        --set PYTHONPATH "$PYTHONPATH:$out/share/Responder" \
        --add-flags "$out/share/Responder/Responder.py" \
        --run "mkdir -p /tmp/Responder"

      substituteInPlace $out/share/Responder/Responder.conf \
        --replace "Responder-Session.log" "/tmp/Responder/Responder-Session.log" \
        --replace "Poisoners-Session.log" "/tmp/Responder/Poisoners-Session.log" \
        --replace "Analyzer-Session.log" "/tmp/Responder/Analyzer-Session.log" \
        --replace "Config-Responder.log" "/tmp/Responder/Config-Responder.log" \
        --replace "Responder.db" "/tmp/Responder/Responder.db"

      runHook postInstall

      runHook postPatch
    '';

    postInstall = ''
      wrapProgram $out/bin/responder \
        --run "mkdir -p /tmp/Responder/certs && ${prev.openssl}/bin/openssl genrsa -out /tmp/Responder/certs/responder.key 2048 && ${prev.openssl}/bin/openssl req -new -x509 -days 3650 -key /tmp/Responder/certs/responder.key -out /tmp/Responder/certs/responder.crt -subj '/'"
    '';

    postPatch = ''
      if [ -f $out/share/Responder/settings.py ]; then
        substituteInPlace $out/share/Responder/settings.py \
          --replace "self.LogDir = os.path.join(self.ResponderPATH, 'logs')" "self.LogDir = os.path.join('/tmp/Responder/', 'logs')"
      fi

      if [ -f $out/share/Responder/utils.py ]; then
        substituteInPlace $out/share/Responder/utils.py \
          --replace "logfile = os.path.join(settings.Config.ResponderPATH, 'logs', fname)" "logfile = os.path.join('/tmp/Responder/', 'logs', fname)"
      fi

      if [ -f $out/share/Responder/Responder.py ]; then
        substituteInPlace $out/share/Responder/Responder.py \
          --replace "certs/responder.crt" "/tmp/Responder/certs/responder.crt" \
          --replace "certs/responder.key" "/tmp/Responder/certs/responder.key"
      fi

      if [ -f $out/share/Responder/Responder.conf ]; then
        substituteInPlace $out/share/Responder/Responder.conf \
          --replace "certs/responder.crt" "/tmp/Responder/certs/responder.crt" \
          --replace "certs/responder.key" "/tmp/Responder/certs/responder.key"
      fi
    '';
  });
}
