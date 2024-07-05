{ config, lib, pkgsx86_64_v3, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgsx86_64_v3; [
    git
    nix-index
    home-manager
    scx
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
    pkgsx86_64_v3.evil-winrm.overrideAttrs (o: {
      nativeBuildInputs = o.nativeBuildInputs ++ [ pkgsx86_64_v3.makeWrapper ];
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
    binwalk
    foremost
    scalpel
    pdf-parser
    pdfid
    soapui
    cryptsetup
    audacity
    dbeaver-bin
    filezilla
    gnome.ghex
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
    clamav
    dig
    steghide
    stegseek
    xsser
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
    #kdePackages.krdc
    remmina
    avalonia-ilspy
    aha
    pciutils
    clinfo
    glxinfo
    vulkan-tools
    wayland-utils
  ];
}
