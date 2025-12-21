_final: prev: {
  metasploit = prev.metasploit.overrideAttrs (oldAttrs: rec {
    version = "6.4.99";

    src = prev.fetchFromGitHub {
      owner = "rapid7";
      repo = "metasploit-framework";
      rev = "e670167fe11b5b10125b8d5136113396d18b3c3c";
      hash = "sha256-qT3FeF1hK1fsEUQ+uXx7CtzBnKsYJRwDoiCyqkggR1A=";
    };

    # Fix Rails version compatibility issues and missing gems
    postPatch = (oldAttrs.postPatch or "") + ''
      # Comment out the strict ActionView version check in application.rb
      if [ -f config/application.rb ]; then
        sed -i "s/raise unless ActionView::VERSION::STRING == '7.2.2.2'/# &/" config/application.rb
        # Change Rails load_defaults from 7.2 to 7.0 to match nixpkgs Rails version
        sed -i "s/config.load_defaults 7.2/config.load_defaults 7.0/" config/application.rb
      fi
      
      # Fix missing parallel gem by commenting out its usage in metadata/store.rb
      if [ -f lib/msf/core/modules/metadata/store.rb ]; then
        sed -i "s/require 'parallel'/# &/" lib/msf/core/modules/metadata/store.rb
        # Replace Parallel.map with regular map - remove the threading options
        sed -i "s/Parallel\.map(files, in_threads: Etc\.nprocessors \* 2)/files.map/" lib/msf/core/modules/metadata/store.rb
      fi
      
      # Fix missing Rex::Socket::Proxies constant in opt.rb
      if [ -f lib/msf/core/opt.rb ]; then
        # Replace the dynamic proxy types lookup with a static string
        sed -i 's/Rex::Socket::Proxies\.supported_types\.join('"'"', '"'"')/["socks4", "socks5", "http"].join(", ")/' lib/msf/core/opt.rb
      fi
    '';
  });
}
