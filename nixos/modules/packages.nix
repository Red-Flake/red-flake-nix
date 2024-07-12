{ config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    nix-index
    home-manager
    file
    gparted
    tree
    vim
    nano
    wget
    unzip
    unrar
    htop
    btop
    gnumake
    cmake
    fastfetch
    lsb-release
    distrobox
    boxbuddy
    nmap
    socat
    rlwrap
    thefuck
    dfc
    zsh
    openvpn
    firefox-bin
    bloodhound
    bloodhound-py
    ffuf
    feroxbuster
    kerbrute
    smbmap
    wafw00f
    nikto
    commix
    davtest
    httrack
    joomscan
    whatweb
    sqlitebrowser
    cewl
    crunch
    (let
      openssl_conf = pkgs.writeText "openssl.conf" ''
        openssl_conf = openssl_init

        [openssl_init]
        providers = provider_sect

        [provider_sect]
        default = default_sect
        legacy = legacy_sect

        [default_sect]
        activate = 1

        [legacy_sect]
        activate = 1
      '';
    in
    pkgs.evil-winrm.overrideAttrs (o: {
      nativeBuildInputs = o.nativeBuildInputs ++ [ pkgs.makeWrapper ];
      postFixup =
        (o.postFixup or "")
        + ''
          wrapProgram $out/bin/evil-winrm \
            --prefix OPENSSL_CONF : ${openssl_conf.outPath}
        '';
    }))
    hashid
    hash-identifier
    hashcat
    john
    vscodium
    thc-hydra
    onesixtyone
    ncrack
    aircrack-ng
    reaverwps
    wifite2
    apktool
    cutter
    cutterPlugins.jsdec
    cutterPlugins.rz-ghidra
    edb
    ghidra-bin
    jadx
    radare2
    social-engineer-toolkit
    ettercap
    bettercap
    macchanger
    responder
    tcpdump
    zeek
    proxychains-ng
    python311Packages.binwalk-full
    foremost
    scalpel
    pdf-parser
    pdfid
    soapui
    cryptsetup
    audacity
    dbeaver-bin
    filezilla
    ghex
    keepassxc
    powershell
    sonic-visualiser
    jq
    openldap
    ntp
    nfs-utils
    openssh
    dotnet-sdk_8
    dotnet-runtime_8
    dotnet-aspnetcore_8
    updog
    ngrok
    redis
    imagemagick
    strace
    # clamav broken at the moment
    #clamav
    dig
    steghide
    stegseek
    # xsser broken at the moment due to python nose
    #xsser
    lsd
    bat
    android-tools
    samba
    oletools
    exiftool
    man
    less
    whois
    exploitdb
    grc
    dnsenum
    dnsrecon
    libvncserver
    burpsuite
    ldapdomaindump
    certipy
    netexec
    enum4linux-ng
    wordlists
    rockyou
    metasploit
    sqlmap
    freerdp3
    pwndbg
    gef
    mariadb
    vesktop
    irssi
    telegram-desktop
    libreoffice-qt6-fresh
    freeoffice
    lshw
    lshw-gui
    krita
    mpv
    vlc
    pidgin
    thunderbird-bin
    tor-browser
    wineWowPackages.stable
    winetricks
    wineWowPackages.waylandFull
    bottles
    helvum
    python312Packages.impacket
    mission-center
    wpscan
    joomscan
    psmisc
    # krdc broken: Unknown error
    #kdePackages.krdc
    remmina
    avalonia-ilspy
    aha
    pciutils
    clinfo
    glxinfo
    vulkan-tools
    wayland-utils
    python312Packages.patator
    jdk
    sqlcmd
    sqsh
  ];
}
