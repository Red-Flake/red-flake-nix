{
  config,
  pkgs,
  lib,
  ...
}:

# BloodHound-CE needs Neo4j 4.4.11 for compatibility

# setup correct supported Neo4j GDS plugin for the correct neo4j version
# see: https://neo4j.com/docs/graph-data-science/current/installation/supported-neo4j-versions/
# use gds version 2.6.x for neo4j 4.4.11
# lets go with latest 2.6.x version: 2.6.8 (2024-06-28)

# also install apoc-4.4.0.24-core.jar plugin for neo4j 4.4.11
# for Neo4j 4.4.11, the APOC docs’ matrix says to use APOC 4.4.0.24 for all 4.4.x releases. The newer APOC jars (e.g. 4.4.0.33/35) call Config.expandCommands() which doesn’t exist in 4.4.11.
# from: https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/tag/4.4.0.24
# see: https://github.com/SpecterOps/BloodHound/blob/03454913830fec12eebc4451dca8af8b3b3c44d7/tools/docker-compose/neo4j.Dockerfile#L28
# see: https://neo4j.com/docs/graph-data-science/current/installation/supported-neo4j-versions/

# Match GDS & APOC to Neo4j 4.4.11
let
  neo4jPkg = config.services.neo4j.package; # <- uses your pinned 4.4.11

  gdsVersion = "2.6.8"; # compatible with 4.4.11
  gdsJarName = "neo4j-graph-data-science-${gdsVersion}.jar";
  gdsJar = pkgs.fetchurl {
    url = "https://github.com/neo4j/graph-data-science/releases/download/${gdsVersion}/${gdsJarName}";
    sha256 = "sha256-hzEakrAEUHsEOm0u9i6pbzemwKrbWJGqcY6ZGLip5Uk=";
  };

  apocVersion = "4.4.0.24"; # as being compatible with 4.4.11
  apocJarName = "apoc-${apocVersion}-core.jar";
  apocJar = pkgs.fetchurl {
    url = "https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/${apocVersion}/${apocJarName}";
    sha256 = "sha256-doaN5k+i3SmKmsxWx4OcwDzeTokRbV4OAGJOl4G+Tkc=";
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

    # Install (symlink) APOC plugin immutably
    if [ ! -e /var/lib/neo4j/plugins/${apocJarName} ]; then
      ln -sfn ${apocJar} /var/lib/neo4j/plugins/${apocJarName}
      chown -h neo4j:neo4j /var/lib/neo4j/plugins/${apocJarName}
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
