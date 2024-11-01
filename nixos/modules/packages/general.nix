{ inputs, config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    netcat-gnu
    file
    gparted
    tree
    wget
    unzip
    unrar
    htop
    btop
    fastfetch
    lsb-release
    socat
    rlwrap
    thefuck
    dfc
    zsh
    openvpn
    macchanger
    soapui
    ghex
    jq
    ntp
    redis
    imagemagick
    strace
    # clamav broken at the moment
    #clamav
    # xsser broken at the moment due to python nose
    #xsser
    lsd
    bat
    man
    less
    grc
    libvncserver
    lshw
    lshw-gui
    thunderbird-bin
    helvum
    mission-center
    psmisc
    aha
    pciutils
    clinfo
    glxinfo
    vulkan-tools
    wayland-utils
    acpi
    inetutils
  ];
}
