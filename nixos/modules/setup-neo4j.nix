{ pkgs, ... }:

{
  # run script to automatically set the neo4j password to Password1337
  system.activationScripts.setup-neo4j = {
    text = ''
      ${pkgs.bash}/bin/bash -c "NEO4J_CONF=/var/lib/neo4j/conf/ /run/current-system/sw/bin/neo4j-admin set-initial-password Password1337"
    '';
  };
}
