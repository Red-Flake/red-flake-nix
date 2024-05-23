# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # nix settings
  #
  ## Convert to flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Set default sddm session to Plasma wayland
  services.displayManager.defaultSession = "plasma";

  # Launch SDDM in Wayland too
  services.displayManager.sddm.wayland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "deadacute";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."pascal" = {
    isNormalUser = true;
    description = "Pascal";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" "adm" "uucp" "lp" "sys"];
  };

  programs.fuse.userAllowOther = true;
  # Home-Manager
  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    users = {
      "pascal" = import ./home.nix;
    };
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "pascal";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    flat-remix-icon-theme
    meslo-lgs-nf
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
    evil-winrm
    hashid
    hash-identifier
    hashcat
    vscodium
    thc-hydra
    onesixtyone
    ncrack
    aircrack-ng
    reaverwps
    wifite2
    apktool
    #cutter
    #cutterPlugins.jsdec
    #cutterPlugins.rz-ghidra
    edb
    ghidra-bin
    jadx
    radare2
    social-engineer-toolkit
    bettercap
    macchanger
    responder
    tcpdump
    wireshark
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
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable OpenSSH password authentication
  services.openssh.settings.PasswordAuthentication = true;

  # Configure Virtualization
  ## Enable Docker
  virtualisation.docker.enable = true;

  ## Enable Docker rootless mode
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
