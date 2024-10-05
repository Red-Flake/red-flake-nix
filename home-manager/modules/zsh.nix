{ config, lib, pkgs, ... }:
let
  # load the configuration that we was generated the first
  # time zsh were loaded with powerlevel enabled.
  # Make sure to comment this part (and the sourcing part below)
  # before you ran powerlevel for the first time or if you want to run
  # again 'p10k configure'. Then, copy the generated file as:
  # $ mv ~/.p10k.zsh p10k-config/p10k.zsh
  configThemeNormal = "p10k.zsh";
  configThemeTTY = "p10k-portable.zsh";
in
{
  fonts.fontconfig.enable = true;

    programs = {
          zsh = {
                ## See options: https://nix-community.github.io/home-manager/options.xhtml

                # enable zsh
                enable = true;

                # Enable zsh completion.
                enableCompletion = true;

                # Enable zsh autosuggestions
                autosuggestion.enable = true;

                # Enable zsh syntax highlighting.
                syntaxHighlighting.enable = true;

                # Commands that should be added to top of {file}.zshrc.
                initExtraFirst = ''
                  # The powerlevel theme I'm using is distgusting in TTY, let's default
                  # to something else
                  # See https://github.com/romkatv/powerlevel10k/issues/325
                  # Instead of sourcing this file you could also add another plugin as
                  # this, and it will automatically load the file for us
                  # (but this way it is not possible to conditionally load a file)
                  # {
                  #   name = "powerlevel10k-config";
                  #   src = lib.cleanSource ./p10k-config;
                  #   file = "p10k.zsh";
                  # }
                  if zmodload zsh/terminfo && (( terminfo[colors] >= 256 )); then
                    [[ ! -f ${configThemeNormal} ]] || source ${configThemeNormal}
                  else
                    [[ ! -f ${configThemeTTY} ]] || source ${configThemeTTY}
                  fi
                '';

                # Extra commands that should be added to {file}.zshrc.
                initExtra = ''
                    # disable nomatch to fix weird compatility issues with bash
                    setopt +o nomatch
                '';

                plugins = [
                  {
                    # A prompt will appear the first time to configure it properly
                    # make sure to select MesloLGS NF as the font in Konsole
                    name = "powerlevel10k";
                    src = pkgs.zsh-powerlevel10k;
                    file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                  }
                  {
                    name = "powerlevel10k-config";
                    src = ./p10k-config;
                    file = "${configThemeNormal}";
                  }
                ];

                oh-my-zsh = {
                    # enable oh-my-zsh
                    enable = true;

                    plugins = [
                        "git"
                        "docker"
                        "colorize"
                        "colored-man-pages"
                        "sudo"
                        "z"
                    ];

                };

                # define shell aliases which are substituted anywhere on a line
                # https://home-manager-options.extranix.com/?query=programs.zsh.shellGlobalAliases&release=master
                shellGlobalAliases = {
                    # general
                    ls = "lsd";
                    ll = "lsd -la";
                    la = "lsd -la";
                    lsa = "lsd -la";
                    tree = "lsd --tree -a";
                    cat = "bat";
                    pcat = "'cat'";
                    cme = "nxc";
                    crackmapexec = "netexec";
                    joomscan = "joomscan.pl";
                    davtest = "davtest.pl";
                    patator = "patator.py";
                    pdf-parser = "pdf-parser.py";
                    ysoserial = "java -jar /usr/share/tools/Deserialization/ysoserial-all.jar";
                    code = "codium";
                    vscode = "codium";
                    vscodium = "codium";

                    # nixos
                    redflake-rebuild = "bash <(curl -L https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/rebuild.sh)";
                    
                    # custom reverse shell handler
                    handler = "echo -n \"Enter the port number: \"; read port && stty raw -echo; (echo \"/bin/python3 -c \\\"import pty;pty.spawn('/bin/bash')\\\" || /bin/python -c \\\"import pty;pty.spawn('/bin/bash')\\\" || /bin/python2 -c \\\"import pty;pty.spawn('/bin/bash')\\\" || /bin/ruby -e \\\"exec '/bin/bash'\\\" || /bin/perl -e \\\"exec '/bin/bash';\\\" || /bin/lua -e \\\"require('os');os.execute('/bin/bash')\\\"\"; echo \"stty$(stty -a | awk -F ';' '{print $2 $3}' | head -n 1)\"; echo \"export TERM=xterm-256color\"; echo \"export SHELL=/bin/bash\"; echo reset; /bin/cat) | nc -lvnp \"$port\" && reset";

                    # shell aliases
                    python3-shell = "nix-shell -p python312 python312Packages.pip python312Packages.pipx python312Packages.requests python312Packages.pycryptodome python312Packages.pycrypto";
                    python-shell = "python3-shell";
                    python2-shell = "NIXPKGS_ALLOW_INSECURE=1 nix-shell -p python2";
                    ruby-shell = "nix-shell -p ruby bundler";
                    node-shell = "nix-shell -p nodePackages_latest.nodejs";
                    c-shell = "nix-shell -p gcc gnumake cmake";
                    cpp-shell ="c-shell";
                    rust-shell = "nix-shell -p rustup --command 'rustup default stable; return'";
                    php-shell = "nix-shell -p php";
                    go-shell = "nix-shell -p go";

                    ## impacket
                    impacket = "ls --color=auto ${pkgs.python312Packages.impacket-patched}/bin/";
                    impacket-addcomputer = "addcomputer.py";
                    impacket-atexec = "atexec.py";
                    impacket-dcomexec = "dcomexec.py";
                    impacket-dpapi = "dpapi.py";
                    impacket-dacledit = "dacledit.py";
                    impacket-esentutl = "esentutl.py";
                    impacket-exchanger = "exchanger.py";
                    impacket-findDelegation = "findDelegation.py";
                    impacket-GetGPPPassword = "Get-GPPPassword.py";
                    impacket-GetADUsers = "GetADUsers.py";
                    impacket-getArch = "getArch.py";
                    impacket-GetNPUsers = "GetNPUsers.py";
                    impacket-getPac = "getPac.py";
                    impacket-getST = "getST.py";
                    impacket-getTGT = "getTGT.py";
                    impacket-GetUserSPNs = "GetUserSPNs.py";
                    impacket-goldenPac = "goldenPac.py";
                    impacket-karmaSMB = "karmaSMB.py";
                    impacket-kintercept = "kintercept.py";
                    impacket-lookupsid = "lookupsid.py";
                    impacket-mimikatz = "mimikatz.py";
                    impacket-mqtt_check = "mqtt_check.py";
                    impacket-mssqlclient = "mssqlclient.py";
                    impacket-mssqlinstance = "mssqlinstance.py";
                    impacket-netview = "netview.py";
                    impacket-nmapAnswerMachine = "nmapAnswerMachine.py";
                    impacket-ntfsread = "ntfs-read.py";
                    impacket-ntlmrelayx = "ntlmrelayx.py";
                    impacket-ping = "ping.py";
                    impacket-ping6 = "ping6.py";
                    impacket-psexec = "psexec.py";
                    impacket-raiseChild = "raiseChild.py";
                    impacket-rbcd = "rbcd.py";
                    impacket-rdpcheck = "rdp_check.py";
                    impacket-reg = "reg.py";
                    impacket-registryread = "registry-read.py";
                    impacket-rpcdump = "rpcdump.py";
                    impacket-rpcmap = "rpcmap.py";
                    impacket-sambaPipe = "sambaPipe.py";
                    impacket-samrdump = "samrdump.py";
                    impacket-secretsdump = "secretsdump.py";
                    impacket-services = "services.py";
                    impacket-smbclient = "smbclient.py";
                    impacket-smbexec = "smbexec.py";
                    impacket-smbpasswd = "smbpasswd.py";
                    impacket-smbrelayx = "smbrelayx.py";
                    impacket-smbserver = "smbserver.py";
                    impacket-sniff = "sniff.py";
                    impacket-sniffer = "sniffer.py";
                    impacket-split = "split.py";
                    impacket-ticketConverter = "ticketConverter.py";
                    impacket-ticketer = "ticketer.py";
                    impacket-wmiexec = "wmiexec.py";
                    impacket-wmipersist = "wmipersist.py";
                    impacket-wmiquery = "wmiquery.py";

                    ## distrobox
                    #arch-box = "distrobox create -n arch -i archlinux:latest --additional-packages 'git nano' --init && distrobox enter archlinux"; # disabled for now due to issues
                    kali-box = "distrobox create -n kali -i docker.io/kalilinux/kali-rolling:latest --additional-packages 'git nano neofetch' --init && distrobox enter kali";
                    debian-box = "distrobox create -n debian -i debian:latest --additional-packages 'systemd libpam-systemd git nano neofetch' --init && distrobox enter debian";
                    ubuntu-box = "distrobox create -n ubuntu -i ubuntu:latest --additional-packages 'git nano neofetch' --init && distrobox enter ubuntu";
                    fedora-box = "distrobox create -n fedora -i fedora:latest --additional-packages 'git nano neofetch' --init && distrobox enter fedora";

                    ## john
                    "1password2john" = "1password2john.py";
                    adxcsouf2john = "adxcsouf2john.py";
                    aem2john = "aem2john.py";
                    aix2john = "aix2john.py";
                    andotp2john = "andotp2john.py";
                    androidbackup2john = "androidbackup2john.py";
                    androidfde2john = "androidfde2john.py";
                    ansible2john = "ansible2john.py";
                    apex2john = "apex2john.py";
                    apop2john = "apop2john.py";
                    applenotes2john = "applenotes2john.py";
                    aruba2john = "aruba2john.py";
                    axcrypt2john = "axcrypt2john.py";
                    bestcrypt2john = "bestcrypt2john.py";
                    bitcoin2john = "bitcoin2john.py";
                    bitshares2john = "bitshares2john.py";
                    bitwarden2john = "bitwarden2john.py";
                    bks2john = "bks2john.py";
                    blockchain2john = "blockchain2john.py";
                    cardano2john = "cardano2john.py";
                    ccache2john = "ccache2john.py";
                    cracf2john = "cracf2john.py";
                    dashlane2john = "dashlane2john.py";
                    deepsound2john = "deepsound2john.py";
                    diskcryptor2john = "diskcryptor2john.py";
                    dmg2john = "dmg2john.py";
                    DPAPImk2john = "DPAPImk2john.py";
                    ecryptfs2john = "ecryptfs2john.py";
                    ejabberd2john = "ejabberd2john.py";
                    electrum2john = "electrum2john.py";
                    encdatavault2john = "encdatavault2john.py";
                    encfs2john = "encfs2john.py";
                    enpass2john = "enpass2john.py";
                    enpass5tojohn = "enpass5tojohn.py";
                    ethereum2john = "ethereum2john.py";
                    filezilla2john = "filezilla2john.py";
                    geli2john = "geli2john.py";
                    hccapx2john = "hccapx2john.py";
                    htdigest2john = "htdigest2john.py";
                    ibmiscanner2john = "ibmiscanner2john.py";
                    ikescan2john = "ikescan2john.py";
                    iwork2john = "iwork2john.py";
                    kdcdump2john = "kdcdump2john.py";
                    keychain2john = "keychain2john.py";
                    keyring2john = "keyring2john.py";
                    keystore2john = "keystore2john.py";
                    kirbi2john = "kirbi2john.py";
                    known_hosts2john = "known_hosts2john.py";
                    krb2john = "krb2john.py";
                    kwallet2john = "kwallet2john.py";
                    lastpass2john = "lastpass2john.py";
                    libreoffice2john = "libreoffice2john.py";
                    lotus2john = "lotus2john.py";
                    luks2john = "luks2john.py";
                    mac2john_alt = "mac2john-alt.py";
                    mac2john = "mac2john.py";
                    mcafee_epo2john = "mcafee_epo2john.py";
                    monero2john = "monero2john.py";
                    money2john = "money2john.py";
                    mosquitto2john = "mosquitto2john.py";
                    mozilla2john = "mozilla2john.py";
                    multibit2john = "multibit2john.py";
                    neo2john = "neo2john.py";
                    netscreen = "netscreen.py";
                    office2john = "office2john.py";
                    openbsd_softraid2john = "openbsd_softraid2john.py";
                    openssl2john = "openssl2john.py";
                    padlock2john = "padlock2john.py";
                    pcap2john = "pcap2john.py";
                    pdf2john = "pdf2john.py";
                    pem2john = "pem2john.py";
                    pfx2john = "pfx2john.py";
                    pgpdisk2john = "pgpdisk2john.py";
                    pgpsda2john = "pgpsda2john.py";
                    pgpwde2john = "pgpwde2john.py";
                    prosody2john = "prosody2john.py";
                    ps_token2john = "ps_token2john.py";
                    pse2john = "pse2john.py";
                    pwsafe2john = "pwsafe2john.py";
                    radius2john = "radius2john.py";
                    restic2john = "restic2john.py";
                    sense2john = "sense2john.py";
                    signal2john = "signal2john.py";
                    sipdump2john = "sipdump2john.py";
                    ssh2john = "ssh2john.py";
                    sspr2john = "sspr2john.py";
                    staroffice2john = "staroffice2john.py";
                    strip2john = "strip2john.py";
                    telegram2john = "telegram2john.py";
                    tezos2john = "tezos2john.py";
                    truecrypt2john = "truecrypt2john.py";
                    vmx2john = "vmx2john.py";
                    zed2john = "zed2john.py";
                    "7z2john" = "7z2john.pl";
                    atmail2john = "atmail2john.pl";
                    cisco2john = "cisco2john.pl";
                    fuzz_option = "fuzz_option.pl";
                    hextoraw = "hextoraw.pl";
                    ios7tojohn = "ios7tojohn.pl";
                    itunes_backup2john = "itunes_backup2john.pl";
                    ldif2john = "ldif2john.pl";
                    lion2john_alt = "lion2john-alt.pl";
                    lion2john = "lion2john.pl";
                    netntlm = "netntlm.pl";
                    potcheck = "potcheck.pl";
                    rexgen2rules = "rexgen2rules.pl";
                    rulestack = "rulestack.pl";
                    sap2john = "sap2john.pl";
                    sha_dump = "sha-dump.pl";
                    sha_test = "sha-test.pl";
                    unrule = "unrule.pl";
                    vdi2john = "vdi2john.pl";
                };

                # define session variables
                # https://home-manager-options.extranix.com/?query=programs.zsh.localVariables&release=master
                localVariables = {
                    LANG = "en_US.UTF-8";
                    EDITOR = "vim";
                    XDG_RUNTIME_DIR = "/run/user/$UID";
                };

      };
   };  
}
