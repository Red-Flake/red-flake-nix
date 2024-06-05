{ pkgs, lib, ... }:

{
  # run script to automatically set the neo4j password to Password1337
  system.activationScripts.setup-neo4j = {
    text = ''
      NEO4J_CONF=/var/lib/neo4j/conf ${lib.getExe' pkgs.neo4j "neo4j-admin"} dbms set-initial-password Password1337
    '';
  };
}
