# responder-overlay.nix
_final: prev:
{
  # FIX for responder: see https://github.com/NixOS/nixpkgs/issues/255281#issuecomment-2244250577
  responder-patched = prev.responder.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs or [ ] ++ [ prev.openssl prev.coreutils ];

    installPhase = ''
      runHook preInstall

      # Define common paths for use in this shell script.
      responderDir="/usr/share/responder"
      certsDir="$responderDir/certs"
      logsDir="$responderDir/logs"

      mkdir -p $out/bin $out/share/Responder
      cp -R . $out/share/Responder

      # Wrap the responder binary.
      makeWrapper ${prev.python3.interpreter} $out/bin/responder \
        --set PYTHONPATH "$PYTHONPATH:$out/share/Responder" \
        --add-flags "$out/share/Responder/Responder.py" \
        --run "mkdir -p $responderDir"

      # Adjust logging and DB paths in Responder.conf using the literal path.
      substituteInPlace $out/share/Responder/Responder.conf \
        --replace-quiet "Responder-Session.log" "$logsDir/Responder-Session.log" \
        --replace-quiet "Poisoners-Session.log" "$logsDir/Poisoners-Session.log" \
        --replace-quiet "Analyzer-Session.log" "$logsDir/Analyzer-Session.log" \
        --replace-quiet "Config-Responder.log" "$logsDir/Config-Responder.log" \
        --replace-quiet "Responder.db" "$responderDir/Responder.db"

      runHook postInstall
      runHook postPatch
    '';

    postInstall = ''
      # Define common paths.
      responderDir="/usr/share/responder"
      certsDir="$responderDir/certs"
      logsDir="$responderDir/logs"

      # Further wrap the binary to generate certificates and copy config if needed.
      wrapProgram $out/bin/responder \
        --run "mkdir -p $certsDir && ${prev.openssl}/bin/openssl genrsa -out $certsDir/responder.key 2048 && ${prev.openssl}/bin/openssl req -new -x509 -days 3650 -key $certsDir/responder.key -out $certsDir/responder.crt -subj '/'" \
        --run "mkdir -p /etc/responder && if [ ! -f /etc/responder/Responder.conf ]; then cp $out/share/Responder/Responder.conf /etc/responder/Responder.conf && chmod +w /etc/responder/Responder.conf; fi"
    '';

    postPatch = ''
      # Define common paths.
      responderDir="/usr/share/responder"
      certsDir="$responderDir/certs"
      logsDir="$responderDir/logs"

      if [ -f $out/share/Responder/settings.py ]; then
        substituteInPlace $out/share/Responder/settings.py \
          --replace-quiet "self.LogDir = os.path.join(self.ResponderPATH, 'logs')" "self.LogDir = '$logsDir'" \
          --replace-quiet "os.path.join(self.ResponderPATH, 'Responder.conf')" "'/etc/responder/Responder.conf'"
      fi

      if [ -f $out/share/Responder/utils.py ]; then
        substituteInPlace $out/share/Responder/utils.py \
          --replace-quiet "logfile = os.path.join(settings.Config.ResponderPATH, 'logs', fname)" "logfile = os.path.join('$logsDir', fname)"
      fi

      if [ -f $out/share/Responder/Responder.py ]; then
        substituteInPlace $out/share/Responder/Responder.py \
          --replace-quiet "certs/responder.crt" "$certsDir/responder.crt" \
          --replace-quiet "certs/responder.key" "$certsDir/responder.key"
      fi

      if [ -f $out/share/Responder/Responder.conf ]; then
        substituteInPlace $out/share/Responder/Responder.conf \
          --replace-quiet "certs/responder.crt" "$certsDir/responder.crt" \
          --replace-quiet "certs/responder.key" "$certsDir/responder.key"
      fi
    '';
  });
}
