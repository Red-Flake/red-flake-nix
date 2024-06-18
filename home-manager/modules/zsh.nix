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
                    screenfetch = "fastfetch";
                    neofetch = "fastfetch";
                    ls = "lsd";
                    ll = "lsd -la";
                    la = "lsd -la";
                    lsa = "lsd -la";
                    tree = "lsd --tree";
                    cat = "bat";
                    cme = "nxc";
                    crackmapexec = "netexec";
                    python3-shell = "nix-shell -p python312 python312Packages.pip python312Packages.pipx";
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
                };

                # define session variables
                # https://home-manager-options.extranix.com/?query=programs.zsh.localVariables&release=master
                localVariables = {
                    LANG = "en_US.UTF-8";
                    EDITOR = "vim";
                };

      };
   };  
}
