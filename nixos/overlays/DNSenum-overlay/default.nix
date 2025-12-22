# DNSenum-overlay.nix
_self: super:

let
  # Fetch an older Nixpkgs revision with Perl 5.34
  oldPkgs = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/d1c3fea7ecbed758168787fe4e4a3157e52bc808.tar.gz";
      sha256 = "0ykm15a690v8lcqf2j899za3j6hak1rm3xixdxsx33nz7n3swsyy";
    })
    {
      system = "x86_64-linux";
    };

  perl-5_34 = oldPkgs.perl.withPackages (ps: with ps; [
    NetDNS
    NetIP
    NetWhoisIP
    NetNetmask
    StringRandom
    XMLWriter
    WWWMechanize
    HTMLParser
    HTMLTree
    HTTPMessage
    EncodeLocale
  ]);

in
{
  dnsenum = super.dnsenum.overrideAttrs (_oldAttrs: {
    buildInputs = with super.perlPackages // oldPkgs.perlPackages; [
      perl-5_34
      oldPkgs.perlPackages.NetWhoisIP
      oldPkgs.perlPackages.WWWMechanize
      oldPkgs.perlPackages.NetDNS
      oldPkgs.perlPackages.NetIP
      oldPkgs.perlPackages.NetNetmask
      oldPkgs.perlPackages.StringRandom
      oldPkgs.perlPackages.XMLWriter
      oldPkgs.perlPackages.RegexpIPv6
    ];

    installPhase = ''
      runHook preInstall
      install -Dm 755 dnsenum.pl $out/bin/dnsenum
      install -Dm 644 dns.txt -t $out/share
      runHook postInstall
    '';

    postInstall = ''
      wrapProgram $out/bin/dnsenum \
        --prefix PERL5LIB : "$PERL5LIB" \
        --prefix PERL5LIB : "/nix/store/1ybivd54z3xywm7185cqdrd621m2wmfk-perl5.34.0-Net-Whois-IP-1.19/lib/perl5/site_perl" \
        --set PATH ${perl-5_34}/bin:$PATH
    '';

    postPatch = ''
      # Ensure the first line is a valid shebang
      if ! grep -q '^#!/usr/bin/perl' dnsenum.pl; then
        sed -i '1i #!${perl-5_34}/bin/perl' dnsenum.pl
      fi

      # Completely remove all Smartmatch usage (forces it to use regex instead)
      sed -i 's/use experimental "smartmatch";//g' dnsenum.pl
      sed -i 's/no warnings "experimental::smartmatch";//g' dnsenum.pl
      sed -i 's/when/if/g' dnsenum.pl
      sed -i 's/given/for/g' dnsenum.pl
      sed -i 's/\~\~/=~/g' dnsenum.pl
    '';

    meta = with super.lib; {
      homepage = "https://github.com/fwaeytens/dnsenum";
      description = "Tool to enumerate DNS information";
      mainProgram = "dnsenum";
      maintainers = with maintainers; [ c0bw3b ];
      license = licenses.gpl2Plus;
      platforms = platforms.all;
    };
  });
}
