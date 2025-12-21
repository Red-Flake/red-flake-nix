# eyewitness-overlay.nix
self: super: {

  python3Packages = super.python3Packages.override {
    overrides = pself: psuper: {
      pyvirtualdisplay = psuper.pyvirtualdisplay.overrideAttrs (old: {
        postPatch = ''
          substituteInPlace pyvirtualdisplay/xvfb.py \
            --replace '"Xvfb"' '"${super.xorg.xorgserver}/bin/Xvfb"'
          substituteInPlace pyvirtualdisplay/abstractdisplay.py \
            --replace "'Xvfb'" "'${super.xorg.xorgserver}/bin/Xvfb'"
        '';
      });
    };
  };

  eyewitness = super.eyewitness.overrideAttrs (old: {
    dependencies = old.dependencies or [ ] ++ [ super.xorg.xorgserver ];

    postPatch = ''
      substituteInPlace Python/modules/selenium_module.py \
        --replace "from selenium.webdriver.common.desired_capabilities import DesiredCapabilities" "" \
        --replace "capabilities = DesiredCapabilities.FIREFOX.copy()" "" \
        --replace "capabilities.update({'acceptInsecureCerts': True})" "" \
        --replace "driver = webdriver.Firefox(profile, capabilities=capabilities, options=options, service_log_path=cli_parsed.selenium_log_path)" "driver = webdriver.Firefox(options=options)"
    '';

    fixupPhase = ''
      runHook preFixup

      makeWrapper "${super.python3Packages.python.interpreter}" "$out/bin/eyewitness" \
        --set PYTHONPATH "$PYTHONPATH" \
        --add-flags "$out/share/eyewitness/Python/EyeWitness.py" \
        --prefix PATH : "${super.lib.makeBinPath [ super.xorg.xorgserver super.geckodriver super.firefox-esr super.xvfb-run ]}"

      runHook postFixup
    '';
  });

}
