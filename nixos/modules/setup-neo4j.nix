{
  config,
  pkgs,
  lib,
  ...
}:

# setup correct supported Neo4j GDS plugin for the correct neo4j version
# see: https://neo4j.com/docs/graph-data-science/current/installation/supported-neo4j-versions/
# use gds version 2.6.x for neo4j 4.4.11
# lets go with latest 2.6.x version: 2.6.8 (2024-06-28)

# Match GDS to Neo4j 4.4.x
let
  neo4jPkg = config.services.neo4j.package; # <- uses your pinned 4.4.11
  gdsVersion = "2.6.8"; # compatible with 4.4.x
  gdsJarName = "neo4j-graph-data-science-${gdsVersion}.jar";
  gdsJar = pkgs.fetchurl {
    url = "https://github.com/neo4j/graph-data-science/releases/download/${gdsVersion}/${gdsJarName}";
    sha256 = "sha256-hzEakrAEUHsEOm0u9i6pbzemwKrbWJGqcY6ZGLip5Uk=";
  };
in
{
  system.activationScripts.setup-neo4j.text = ''
    set -eu

    # Ensure dirs owned by neo4j
    install -d -m 0700 -o neo4j -g neo4j /var/lib/neo4j/{data,plugins,conf}
    install -d -m 0700 -o neo4j -g neo4j /var/lib/neo4j/data/dbms

    # Install (symlink) GDS plugin immutably
    if [ ! -e /var/lib/neo4j/plugins/${gdsJarName} ]; then
      ln -sfn ${gdsJar} /var/lib/neo4j/plugins/${gdsJarName}
      chown -h neo4j:neo4j /var/lib/neo4j/plugins/${gdsJarName}
    fi

    # Set initial password only once (before first start)
    if [ ! -f /var/lib/neo4j/data/dbms/auth.ini ]; then
      echo "Setting initial Neo4j password…"
      su -s /bin/sh -c \
        'NEO4J_HOME=/var/lib/neo4j NEO4J_CONF=/var/lib/neo4j/conf ${lib.getExe' neo4jPkg "neo4j-admin"} set-initial-password "Password1337"' \
        neo4j || true
    fi
  '';
}
