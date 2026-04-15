# DNSenum overlay
_: prev:
let
  perlLibPath = prev.perlPackages.makeFullPerlPath [
    prev.perlPackages.NetDNS
    prev.perlPackages.NetIP
    prev.perlPackages.NetWhoisIP
    prev.perlPackages.NetNetmask
    prev.perlPackages.StringRandom
    prev.perlPackages.XMLWriter
    prev.perlPackages.WWWMechanize
    prev.perlPackages.HTMLParser
    prev.perlPackages.HTMLTree
    prev.perlPackages.HTTPMessage
    prev.perlPackages.EncodeLocale
  ];
in
{
  dnsenum = prev.dnsenum.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];

    postPatch = (oldAttrs.postPatch or "") + ''
      # Replace deprecated smartmatch usage with explicit membership checks.
      substituteInPlace dnsenum.pl \
        --replace-fail \
          'if (!($rr->can('"'"'address'"'"') && $rr->address ~~ @wildcardaddress) && !($rr->name ~~ @wildcardcname))' \
          'if (!($rr->can('"'"'address'"'"') && grep { defined $_ && $rr->address eq $_ } @wildcardaddress) && !(grep { defined $_ && $rr->name eq $_ } @wildcardcname))'
    '';

    postFixup = (oldAttrs.postFixup or "") + ''
      wrapProgram $out/bin/dnsenum \
        --prefix PERL5LIB : "${perlLibPath}"
    '';
  });
}
