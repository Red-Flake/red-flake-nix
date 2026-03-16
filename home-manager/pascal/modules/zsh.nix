{ lib, pkgs, ... }:
{
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
      initContent = lib.mkBefore ''
        # disable nomatch to fix weird compatility issues with bash
        setopt +o nomatch

        # History improvements
        setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicates from history
        setopt HIST_SAVE_NO_DUPS       # Don't save duplicates to history file
        setopt HIST_REDUCE_BLANKS      # Remove superfluous blanks from history
        setopt HIST_VERIFY             # Show command before executing from history
        setopt SHARE_HISTORY           # Share history between sessions

        # Navigation
        setopt AUTO_CD                 # Type directory name to cd into it

        # Completion caching for faster tab completion
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

        # Async IP caching (non-blocking startup)
        # Cache file persists across shells for the same user
        _IP_CACHE_FILE="/tmp/zsh_ip_cache_$UID"

        _update_ip_cache() {
            local lan_ip vpn_ip=""
            lan_ip="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')"
            for iface in tun0 tun1 tun2 wg0 wg1 proton0 nordlynx; do
                local ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {gsub(/\/.*/, "", $2); print $2; exit}')
                if [[ -n "$ip" ]]; then
                    vpn_ip="$ip"
                    break
                fi
            done
            printf '%s\n%s\n' "$lan_ip" "$vpn_ip" > "$_IP_CACHE_FILE"
        }

        # Fast cache loader - reads 2 lines from local file
        _load_ip_cache() {
            if [[ -f "$_IP_CACHE_FILE" ]]; then
                { read -r _CACHED_LAN_IP; read -r _CACHED_VPN_IP; } < "$_IP_CACHE_FILE"
                export _CACHED_LAN_IP _CACHED_VPN_IP
            fi
        }

        # Initialize empty (will be populated by background job or cache)
        export _CACHED_LAN_IP="" _CACHED_VPN_IP=""

        # Load existing cache immediately (if available from previous shell)
        _load_ip_cache

        # Start background update (disowned - won't block startup)
        { _update_ip_cache } &!

        # Refresh IP cache (call manually or bind to a key)
        refresh-ips() { _update_ip_cache && _load_ip_cache && echo "IPs refreshed: LAN=$_CACHED_LAN_IP VPN=$_CACHED_VPN_IP" }

        # Custom starship init with transient prompt support
        # Based on: https://github.com/starship/starship/issues/888
        if (( $+commands[starship] )); then
            eval "$(starship init zsh)"
            zmodload zsh/datetime

            # Word navigation with Ctrl+Left/Right
            bindkey '^[[1;5D' backward-word
            bindkey '^[[1;5C' forward-word

            # Clear screen widget that resets prompt spacing
            _clear_screen_and_reset() {
                unset _STARSHIP_PROMPT_SHOWN
                zle clear-screen
            }
            zle -N _clear_screen_and_reset
            bindkey '^L' _clear_screen_and_reset

            _starship_build_prompt() {
                # Use pure zsh to count jobs (avoids spawning 3 processes)
                local job_count=''${#jobstates}
                PROMPT="$(starship prompt --terminal-width="$COLUMNS" --status=''${_STARSHIP_LAST_STATUS:-0} --cmd-duration=''${_STARSHIP_LAST_DURATION:-0} --jobs="$job_count")"
                RPROMPT="$(starship prompt --right --terminal-width="$COLUMNS" --status=''${_STARSHIP_LAST_STATUS:-0} --cmd-duration=''${_STARSHIP_LAST_DURATION:-0} --jobs="$job_count")"
            }

            _starship_timer_start() {
                export _MY_CMD_START_TIME=''${EPOCHREALTIME}
            }
            autoload -Uz add-zsh-hook
            add-zsh-hook preexec _starship_timer_start

            _starship_precmd() {
                _STARSHIP_LAST_STATUS=$?
                _STARSHIP_LAST_DURATION=0

                # Add newline between commands, but not on first prompt
                if [[ -n "$_STARSHIP_PROMPT_SHOWN" ]]; then
                    echo
                fi
                _STARSHIP_PROMPT_SHOWN=1
                if [[ -n $_MY_CMD_START_TIME ]]; then
                    local end_time=''${EPOCHREALTIME}
                    _STARSHIP_LAST_DURATION=$(( (end_time - _MY_CMD_START_TIME) * 1000 ))
                    _STARSHIP_LAST_DURATION=''${_STARSHIP_LAST_DURATION%.*}
                fi
                unset _MY_CMD_START_TIME

                _starship_build_prompt
            }
            add-zsh-hook precmd _starship_precmd

            _starship_transient_collapse() {
                if [[ "$CONTEXT" == "start" ]]; then
                    PROMPT="$(starship module character)"
                    RPROMPT=""
                    zle .reset-prompt
                fi
            }
            zle -N zle-line-finish _starship_transient_collapse
        fi

        # Keybindings for history-substring-search (after plugin loads)
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        bindkey '^P' history-substring-search-up
        bindkey '^N' history-substring-search-down
      '';

      # Zsh plugins
      plugins = [
        {
          name = "zsh-z";
          src = pkgs.fetchFromGitHub {
            owner = "agkozak";
            repo = "zsh-z";
            rev = "cf9225feebfae55e557e103e95ce20eca5eff270"; # Pinned commit for reproducibility
            sha256 = "sha256-C79eSOaWNHSJiUGmHzu9d0zO0NdW+dktK21a2niPZm0=";
          };
          file = "zsh-z.plugin.zsh";
        }
        {
          name = "fzf-tab";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "v1.2.0";
            sha256 = "0mnsmfv0bx6np2r6pll43h261v7mh2ic1kd08r7jcwyb5xarfvmb";
          };
          file = "fzf-tab.plugin.zsh";
        }
        {
          name = "zsh-history-substring-search";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-history-substring-search";
            rev = "v1.1.0";
            sha256 = "0vjw4s0h4sams1a1jg9jx92d6hd2swq4z908nbmmm2qnz212y88r";
          };
          file = "zsh-history-substring-search.plugin.zsh";
        }
      ];

      # https://home-manager-options.extranix.com/?query=programs.zsh.shellAliases&release=master
      shellAliases = {
        # Reset prompt spacing flag when clearing screen
        clear = "unset _STARSHIP_PROMPT_SHOWN; command clear";

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
        vscode = "code";
        smbclient-ng = "smbclientng";
        pyftpdlib = "pipx run pyftpdlib";
        uploadserver = "pipx run uploadserver";
        bloodhound-quickwin = "bhqc.py";
        stegsolve = "java -jar /usr/share/tools/Steganography/stegsolve.jar";
        msfconsole = "msfconsole -q";
        mono-csc = "csc";
        proxychains = "proxychains4";
        # Avoid coredumps when fastfetch probes Plasma (it may spawn
        # `plasmashell --version`, which can abort in restricted/sandboxed
        # terminal contexts if Qt can't connect to Wayland/X11).
        fastfetch = "QT_QPA_PLATFORM=offscreen command fastfetch";

        # nixos
        redflake-rebuild = "bash <(curl -L https://raw.githubusercontent.com/Red-Flake/red-flake-nix/main/rebuild.sh)";

        # custom reverse shell handler
        revshell = "echo -n 'Enter the port number: '; read port && stty raw -echo; (echo '/bin/python3 -c \"import pty;pty.spawn(\"/bin/bash\")\" || /bin/python -c \"import pty;pty.spawn(\"/bin/bash\")\" || /bin/python2 -c \"import pty;pty.spawn(\"/bin/bash\")\" || /bin/ruby -e \"exec \"/bin/bash\"\" || /bin/perl -e \"exec \"/bin/bash\";\" || /bin/lua -e \"require(\"os\");os.execute(\"/bin/bash\")\"'; echo 'stty'$(stty -a | awk -F ';' '{print $2 $3}' | head -n 1); echo 'export TERM=xterm-256color'; echo 'export SHELL=/bin/bash'; echo reset; cat) | nc -lvnp \"$port\" && reset";

        # shell aliases
        python3-shell = ''
          _python3_shell() {
            local venv_dir=".venv"
            python3 -m venv "$venv_dir" && \
            source "$venv_dir/bin/activate" && \
            pip install pycryptodome pycryptodomex pwntools requests
          } && _python3_shell
        '';
        python-shell = "python3-shell";
        python2-shell = ''
          _python2_shell() {
            local venv_dir=".venv2"
            # Remove the venv directory if it exists
            [[ -d "$venv_dir" ]] && rm -rf "$venv_dir"
            # Create a new Python 2 venv and activate it
            python2 -m virtualenv "$venv_dir" && \
            source "$venv_dir/bin/activate" && \
            pip install pycryptodome pwntools requests
          } && _python2_shell
        '';
        ruby-shell = "nix-shell -p ruby bundler";
        node-shell = "nix-shell -p nodePackages_latest.nodejs";
        c-shell = "nix-shell -p gcc gnumake cmake";
        cpp-shell = "c-shell";
        rust-shell = "nix-shell -p rustup --command 'rustup default stable; return'";
        php-shell = "nix-shell -p php";
        go-shell = "nix-shell -p go";

        ## impacket
        impacket = "ls --color=auto ${pkgs.python313Packages.impacket}/bin/";
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
        "kirbi2john.py" = "/usr/share/tools/ActiveDirectory/Kerberos/kirbi2john.py";
        kirbi2john = "/usr/share/tools/ActiveDirectory/Kerberos/kirbi2john.py";
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
        EDITOR = "code";
        XDG_RUNTIME_DIR = "/run/user/$UID";
      };

    };

    # fzf - fuzzy finder (required for fzf-tab)
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
