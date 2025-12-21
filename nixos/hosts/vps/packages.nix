{ inputs
, config
, lib
, pkgs
, modulesPath
, ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    netcat-gnu
    file
    tree
    wget
    zip
    unzip
    unrar
    p7zip
    htop
    fastfetch
    lsb-release
    socat
    rlwrap
    dfc
    zsh
    openvpn
    jq
    ntp
    strace
    lsd
    bat
    man
    less
    grc
    lshw
    psmisc
    aha
    pciutils
    clinfo
    inetutils
    libfaketime
    wireguard-tools
    e2fsprogs
    tldr
    sshpass
  ];
}
