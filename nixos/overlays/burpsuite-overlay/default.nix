_final: prev:
let
  loaderSrc = prev.fetchurl {
    url = "https://github.com/Letgamer/burp/releases/download/master/loader.jar";
    hash = "sha256-3W+eXaCnxYoVihBQ2aobDdBkaVkz6+/dxQhw/BQ5xX8=";
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
