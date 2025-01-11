{ pkgs, lib, ... }:

{
  system.activationScripts.setup-neo4j = {
    text = ''
      if [ ! -d /var/lib/neo4j/plugins ]; then
        mkdir -p /var/lib/neo4j/plugins
      fi

      if [ ! -f /var/lib/neo4j/plugins/neo4j-graph-data-science-2.10.1.jar ]; then
        ${lib.getExe' pkgs.wget "wget"} -O /var/lib/neo4j/plugins/neo4j-graph-data-science-2.10.1.jar \
          https://github.com/neo4j/graph-data-science/releases/download/2.10.1/neo4j-graph-data-science-2.10.1.jar
      fi

      # run script to automatically set the neo4j password to Password1337
      NEO4J_CONF=/var/lib/neo4j/conf ${lib.getExe' pkgs.neo4j "neo4j-admin"} dbms set-initial-password Password1337
    '';
  };
}
