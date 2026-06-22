_final: prev:
let
  loaderSrc = prev.fetchurl {
    url = "https://github.com/xiv3r/Burpsuite-Professional/raw/refs/heads/main/loader.jar";
    hash = "sha256-3N8orPNgVUpamNePQDyWzOpQC+JLJ9ArAg4UKCBjfAo=";
  };

  javaOpts = builtins.concatStringsSep " " [
    # As the license challenge-response is bound to the user name
    "-Duser.name=user"
    # Needed to access the ASM classes
    "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED"
    "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED"
    # It is loaded as a java agent
    "-javaagent:${loaderSrc}"
  ];
in
{
  burpsuite = prev.burpsuite.override (old: {
    buildFHSEnv = args:
      old.buildFHSEnv (args
        // {
        runScript =
          builtins.replaceStrings
            [ " -jar " ]
            [ " ${javaOpts} -jar " ]
            args.runScript;
      });
  });
}
