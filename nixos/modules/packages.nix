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

    # FIX for evil-winrm: https://github.com/NixOS/nixpkgs/issues/255276#issuecomment-2208251089
    # Pull request that fixes this issue: https://github.com/NixOS/nixpkgs/pull/324530
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

    # FIX for responder: https://github.com/NixOS/nixpkgs/issues/255281#issuecomment-2229259710
    (pkgs.responder.overrideAttrs (oldAttrs: rec {
      buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.openssl pkgs.coreutils ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/share $out/share/Responder
        cp -R . $out/share/Responder

        makeWrapper ${python3.interpreter} $out/bin/responder \
          --set PYTHONPATH "$PYTHONPATH:$out/bin/Responder.py" \
          --add-flags "$out/share/Responder/Responder.py" \
          --run "mkdir -p /tmp/Responder"

        substituteInPlace $out/share/Responder/Responder.conf \
          --replace "Responder-Session.log" "/tmp/Responder/Responder-Session.log" \
          --replace "Poisoners-Session.log" "/tmp/Responder/Poisoners-Session.log" \
          --replace "Analyzer-Session.log" "/tmp/Responder/Analyzer-Session" \
          --replace "Config-Responder.log" "/tmp/Responder/Config-Responder.log" \
          --replace "Responder.db" "/tmp/Responder/Responder.db"

        runHook postInstall

        runHook postPatch
      '';

      postInstall = ''
        wrapProgram $out/bin/responder \
          --run "mkdir -p /tmp/Responder/certs && ${pkgs.openssl}/bin/openssl genrsa -out /tmp/Responder/certs/responder.key 2048 && ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -key /tmp/Responder/certs/responder.key -out /tmp/Responder/certs/responder.crt -subj '/'"
      '';

      postPatch = ''
        if [ -f $out/share/Responder/settings.py ]; then
          substituteInPlace $out/share/Responder/settings.py \
            --replace "self.LogDir = os.path.join(self.ResponderPATH, 'logs')" "self.LogDir = os.path.join('/tmp/Responder/', 'logs')"
        fi

        if [ -f $out/share/Responder/utils.py ]; then
          substituteInPlace $out/share/Responder/utils.py \
            --replace "logfile = os.path.join(settings.Config.ResponderPATH, 'logs', fname)" "logfile = os.path.join('/tmp/Responder/', 'logs', fname)"
        fi

        if [ -f $out/share/Responder/Responder.py ]; then
          substituteInPlace $out/share/Responder/Responder.py \
            --replace "certs/responder.crt" "/tmp/Responder/certs/responder.crt" \
            --replace "certs/responder.key" "/tmp/Responder/certs/responder.key"
        fi

        if [ -f $out/share/Responder/Responder.conf ]; then
          substituteInPlace $out/share/Responder/Responder.conf \
            --replace "certs/responder.crt" "/tmp/Responder/certs/responder.crt" \
            --replace "certs/responder.key" "/tmp/Responder/certs/responder.key"
        fi
      '';
    }))

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
    python311Packages.patator
    jdk
    sqlcmd
    sqsh
  ];
}
