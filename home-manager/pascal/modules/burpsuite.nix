{
  config,
  lib,
  pkgs,
  ...
}:
{
  # deploy UserConfigCommunity.json
  home.file.".BurpSuite/UserConfigCommunity.json" = {
    source = ./burpsuite/UserConfigCommunity.json;
    recursive = false;
    force = true;
  };

  # deploy UserConfigPro.json
  home.file.".BurpSuite/UserConfigPro.json" = {
    source = ./burpsuite/UserConfigPro.json;
    recursive = false;
    force = true;
  };

  # deploy jruby-complete-10.0.0.1.jar
  home.file.".BurpSuite/jruby-complete-10.0.0.1.jar" = {
    source = ./burpsuite/jruby-complete-10.0.0.1.jar;
    recursive = false;
    force = true;
  };

  # deploy jython-standalone-2.7.4.jar
  home.file.".BurpSuite/jython-standalone-2.7.4.jar" = {
    source = ./burpsuite/jython-standalone-2.7.4.jar;
    recursive = false;
    force = true;
  };
}
