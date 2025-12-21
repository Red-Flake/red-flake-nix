# dnscat2-overlay.nix
_self: super: {
  dnscat2 = super.stdenv.mkDerivation rec {
    pname = "dnscat2";
    version = "0.07";

    # Fetch the dnscat2 repository from GitHub.
    src = super.fetchFromGitHub {
      owner = "Red-Flake";
      repo = "dnscat2";
      rev = "95af647b6a8d2ad20027a8d2bd200acfd00f1cf0";
      sha256 = "sha256-Se9SKG4MfzVNhwwqY6ZzHu0u4VzZeeyyarNGT6ZeFAs=";
    };

    nativeBuildInputs = [
      super.ruby
      super.bundler
      super.makeWrapper
    ];

    # Use Bundler to install the gem dependencies locally.
    buildPhase = ''
      # Use local vendored gems so no network access is needed.
      bundle install --gemfile server/Gemfile --local --path vendor/cache
    '';

    installPhase = ''
        # Copy the entire source tree to the output.
        mkdir -p $out/app
        cp -r . $out/app

        # Create a wrapper script with the appropriate shebang and env variables.
        mkdir -p $out/bin
        cat > $out/bin/dnscat2 <<EOF
      #!/bin/sh
      export GEM_HOME=$out/app/vendor/bundle
      export GEM_PATH=$out/app/vendor/bundle
      export BUNDLE_GEMFILE=$out/app/server/Gemfile
      export BUNDLE_PATH=$out/app/vendor/bundle
      exec ${super.ruby}/bin/ruby -rbundler/setup $out/app/server/dnscat2.rb "\$@"
      EOF
        chmod +x $out/bin/dnscat2
    '';

    meta = with super.lib; {
      description = "dnscat2: A DNS tunneling tool written in Ruby";
      homepage = "https://github.com/Red-Flake/dnscat2";
      license = licenses.bsd3;
      maintainers = [ maintainers.Mag1cByt3s ];
    };
  };
}
