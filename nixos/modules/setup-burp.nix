{ pkgs, ... }:

{
  # run script to automatically provision the Burp Suite CA certificate
  system.activationScripts.setup-burp = {
    text = ''
      if ! [ -f /etc/ssl/certs/BurpSuiteCA.der ]; then
        ${pkgs.bash}/bin/bash -c "${pkgs.toybox}/bin/timeout 60 ${pkgs.burpsuite}/bin/burpsuite < <(${pkgs.toybox}/bin/echo y) &"
        ${pkgs.toybox}/bin/sleep 40
        ${pkgs.curl}/bin/curl http://localhost:8080/cert -o /etc/ssl/certs/BurpSuiteCA.der
      fi
    '';
  };
}
