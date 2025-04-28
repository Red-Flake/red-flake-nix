{ pkgs, lib, ... }:

let
  gdsVersion = "2.12.0";
  gdsJarName = "neo4j-graph-data-science-${gdsVersion}.jar";
  gdsDownloadUrl = "https://github.com/neo4j/graph-data-science/releases/download/${gdsVersion}/${gdsJarName}";
in
{
  system.activationScripts.setup-neo4j = {
    text = ''
      plugins_dir="/var/lib/neo4j/plugins"

      if [ ! -d "$plugins_dir" ]; then
        mkdir -p "$plugins_dir"
      fi

      if [ ! -f "$plugins_dir/${gdsJarName}" ]; then
        echo "Downloading Graph Data Science ${gdsVersion} plugin..."
        ${lib.getExe' pkgs.wget "wget"} -O "$plugins_dir/${gdsJarName}" "${gdsDownloadUrl}"
      fi

      # Set initial Neo4j password
      NEO4J_CONF=/var/lib/neo4j/conf ${lib.getExe' pkgs.neo4j "neo4j-admin"} dbms set-initial-password Password1337
    '';
  };
}
