#!/run/current-system/sw/bin/bash
/run/current-system/sw/bin/bash -c "/run/current-system/sw/bin/timeout 45 /run/current-system/sw/bin/burpsuite < <(/run/current-system/sw/bin/echo y) &"
/run/current-system/sw/bin/sleep 20
/run/current-system/sw/bin/curl http://localhost:8080/cert -o /etc/ssl/certs/BurpSuiteCA.der