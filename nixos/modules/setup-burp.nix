{ pkgsx86_64_v3, ... }:

{
  # run script to automatically provision the Burp Suite CA certificate
  system.activationScripts.setup-burp = {
    text = ''
      if ! [ -f /etc/ssl/certs/BurpSuiteCA.der ]; then
        ${pkgsx86_64_v3.bash}/bin/bash -c "${pkgsx86_64_v3.coreutils}/bin/timeout 60 ${pkgsx86_64_v3.burpsuite}/bin/burpsuite < <(${pkgsx86_64_v3.coreutils}/bin/echo y) &"
        ${pkgsx86_64_v3.coreutils}/bin/sleep 40
        ${pkgsx86_64_v3.curl}/bin/curl http://localhost:8080/cert -o /etc/ssl/certs/BurpSuiteCA.der
      fi
    '';
  };
}
