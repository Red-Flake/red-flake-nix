{ config, lib, pkgs, ... }:

{

  ## .desktop application entries
  xdg.desktopEntries.ghidra = {
    name = "ghidra";
    genericName = "";
    exec = "ghidra";
    icon = "ghidra";
    type = "Application";
    categories = [ "X-reverse_engineering" "X-respond" ];
  };
  xdg.desktopEntries.binwalk = {
    name = "binwalk";
    genericName = "";
    exec = "sh -c \"binwalk -h;\\${SHELL:-zsh}\"";
    icon = "binwalk";
    type = "Application";
    categories = [ "X-forensics" ];
  };
  xdg.desktopEntries.tcpdump = {
    name = "tcpdump";
    genericName = "";
    exec = "sh -c \"tcpdump -h;\\${SHELL:-zsh}\"";
    icon = "tcpdump";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.bpython = {
    name = "bpython";
    genericName = "";
    exec = "sh -c \"bpython;\\${SHELL:-zsh}\"";
    icon = "bpython";
    type = "Application";
    categories = [ "X-Development" "X-Utility" "X-ConsoleOnly" ];
  };
  xdg.desktopEntries.sqlmap = {
    name = "sqlmap";
    genericName = "";
    exec = "sh -c \"sqlmap --wizard;\\${SHELL:-zsh}\"";
    icon = "sqlmap";
    type = "Application";
    categories = [ "X-webapp-analysis" "X-database-assessment" "X-exploitation-tools" ];
  };
  xdg.desktopEntries.macchanger = {
    name = "macchanger";
    genericName = "";
    exec = "sh -c \"macchanger -h;\\${SHELL:-zsh}\"";
    icon = "macchanger";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.aircrack-ng = {
    name = "aircrack-ng";
    genericName = "";
    exec = "sh -c \"aircrack-ng --help;\\${SHELL:-zsh}\"";
    icon = "aircrack-ng";
    type = "Application";
    categories = [ "X-wireless-attacks" ];
  };
  xdg.desktopEntries.beef_start = {
    name = "beef start";
    genericName = "";
    exec = "sh -c \"sudo beef;\\${SHELL:-zsh}\"";
    icon = "beef-xss";
    type = "Application";
    categories = [ "X-exploitation-tools" "X-social-engineering-tools" "X-beef-service" "X-services" ];
  };
  xdg.desktopEntries.ollydbg = {
    name = "ollydbg";
    genericName = "";
    exec = "sh -c \"ollydbg;\\${SHELL:-zsh}\"";
    icon = "ollydbg";
    type = "Application";
    categories = [ "X-reverse_engineering" "X-respond" ];
  };
  xdg.desktopEntries.cewl = {
    name = "cewl";
    genericName = "";
    exec = "sh -c \"cewl --help;\\${SHELL:-zsh}\"";
    icon = "cewl";
    type = "Application";
    categories = [ "X-profile" "X-password-attacks" ];
  };
  xdg.desktopEntries.pdf-parser = {
    name = "pdf-parser";
    genericName = "";
    exec = "sh -c \"pdf-parser -h;\\${SHELL:-zsh}\"";
    icon = "pdf-parser";
    type = "Application";
    categories = [ "X-pdf-forensics-tools"  ];
  };
  xdg.desktopEntries.hash-identifier = {
    name = "hash-identifier";
    genericName = "";
    exec = "hash-identifier";
    icon = "hash-identifier";
    type = "Application";
    categories = [ "X-offline-attacks" ];
  };
  xdg.desktopEntries.commix = {
    name = "commix";
    genericName = "";
    exec = "sh -c \"commix --wizard;\\${SHELL:-zsh}\"";
    icon = "commix";
    type = "Application";
    categories = [ "X-webapp-analysis"  ];
  };
  xdg.desktopEntries.crackmapexec = {
    name = "crackmapexec";
    genericName = "";
    exec = "sh -c \"crackmapexec -h;\\${SHELL:-zsh}\"";
    icon = "crackmapexec";
    type = "Application";
    categories = [ "X-exploitation-tools" "X-pass-hash" ];
  };
  xdg.desktopEntries.john = {
    name = "john";
    genericName = "";
    exec = "sh -c \"john;\\${SHELL:-zsh}\"";
    icon = "john";
    type = "Application";
    categories = [ "X-offline-attacks" "X-password-attacks" ];
  };
  xdg.desktopEntries.ncrack = {
    name = "ncrack";
    genericName = "";
    exec = "sh -c \"ncrack -h;\\${SHELL:-zsh}\"";
    icon = "ncrack";
    type = "Application";
    categories = [ "X-password-attacks" "X-online-attacks"  ];
  };
  xdg.desktopEntries.bettercap = {
    name = "bettercap";
    genericName = "";
    exec = "sh -c \"sudo bettercap;\\${SHELL:-zsh}\"";
    icon = "bettercap";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.veil = {
    name = "veil";
    genericName = "";
    exec = "veil -h";
    icon = "veil";
    type = "Application";
    categories = [ "X-maintaining-access" ];
  };
  xdg.desktopEntries.onesixtyone = {
    name = "onesixtyone";
    genericName = "";
    exec = "sh -c \"onesixtyone;\\${SHELL:-zsh}\"";
    icon = "onesixtyone";
    type = "Application";
    categories = [ "X-snmp-analysis" "X-online-attacks" ];
  };
  xdg.desktopEntries.foremost = {
    name = "foremost";
    genericName = "";
    exec = "sh -c \"foremost -h;\\${SHELL:-zsh}\"";
    icon = "foremost";
    type = "Application";
    categories = [ "X-forensics" "X-forensic-carving-tools" "X-respond" ];
  };
  xdg.desktopEntries.impacket = {
    name = "impacket";
    genericName = "";
    exec = "sh -c \"(cd /usr/bin/ && ls --color=auto impacket-*);\\${SHELL:-zsh}\"";
    icon = "impacket";
    type = "Application";
    categories = [ "X-maintaining-access" "X-pass-hash" "X-respond" ];
  };
  xdg.desktopEntries.powershell = {
    name = "PowerShell";
    genericName = "";
    exec = "pwsh";
    icon = "pwsh";
    type = "Application";
    categories = [ "X-System" "X-Utility"  ];
  };
  xdg.desktopEntries.hydra = {
    name = "hydra";
    genericName = "";
    exec = "sh -c \"hydra | grep --color=auto '^\|Supported services:'; hydra-wizard;\\${SHELL:-zsh}\"";
    icon = "hydra";
    type = "Application";
    categories = [ "X-password-attacks" "X-online-attacks" ];
  };
  xdg.desktopEntries.radare2 = {
    name = "radare2";
    genericName = "";
    exec = "sh -c \"radare2 -h;\\${SHELL:-zsh}\"";
    icon = "radare2";
    type = "Application";
    categories = [ "X-reverse_engineering" ];
  };
  xdg.desktopEntries.apktool = {
    name = "apktool";
    genericName = "";
    exec = "sh -c \"apktool;\\${SHELL:-zsh}\"";
    icon = "apktool";
    type = "Application";
    categories = [ "X-reverse_engineering" "X-android-tools" ];
  };
  xdg.desktopEntries.wifite = {
    name = "wifite";
    genericName = "";
    exec = "sh -c \"wifite --help;\\${SHELL:-zsh}\"";
    icon = "wifite";
    type = "Application";
    categories = [ "X-wireless-attacks" ];
  };
  xdg.desktopEntries.vim = {
    name = "Vim";
    genericName = "Text Editor";
    exec = "vim %F";
    icon = "gvim";
    type = "Application";
    categories = [ "X-Utility" "X-TextEditor" ];
  };
  xdg.desktopEntries.whatweb = {
    name = "whatweb";
    genericName = "";
    exec = "sh -c \"whatweb -h;\\${SHELL:-zsh}\"";
    icon = "whatweb";
    type = "Application";
    categories = [ "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.jadx-gui = {
    name = "jadx-gui";
    genericName = "";
    exec = "jadx-gui";
    icon = "jadx";
    type = "Application";
    categories = [ "X-reverse_engineering" ];
  };
  xdg.desktopEntries.patator = {
    name = "patator";
    genericName = "";
    exec = "sh -c \"patator -h;\\${SHELL:-zsh}\"";
    icon = "patator";
    type = "Application";
    categories = [ "X-online-attacks" ];
  };
  xdg.desktopEntries.btopPlusPlus = {
    name = "btop++";
    genericName = "System Monitor";
    exec = "btop";
    icon = "btop";
    type = "Application";
    categories = [ "X-System" "X-Monitor" "X-ConsoleOnly" ];
  };
  xdg.desktopEntries.wpscan = {
    name = "wpscan";
    genericName = "";
    exec = "sh -c \"wpscan --help;\\${SHELL:-zsh}\"";
    icon = "wpscan";
    type = "Application";
    categories = [ "X-webapp-analysis" "X-cms-identification" "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.social_engineering_toolkit = {
    name = "social engineering toolkit (root)";
    genericName = "";
    exec = "sudo setoolkit";
    icon = "set";
    type = "Application";
    categories = [ "X-exploitation-tools" "X-social-engineering-tools" ];
  };
  xdg.desktopEntries.smbmap = {
    name = "smbmap";
    genericName = "";
    exec = "sh -c \"smbmap -h;\\${SHELL:-zsh}\"";
    icon = "smbmap";
    type = "Application";
    categories = [ "X-smb-analysis" "X-pass-hash" ];
  };
  xdg.desktopEntries.hashcat = {
    name = "hashcat";
    genericName = "";
    exec = "sh -c \"hashcat --help;\\${SHELL:-zsh}\"";
    icon = "hashcat";
    type = "Application";
    categories = [ "X-offline-attacks" "X-password-attacks" ];
  };
  xdg.desktopEntries.httrack = {
    name = "httrack";
    genericName = "";
    exec = "sh -c \"httrack -h;\\${SHELL:-zsh}\"";
    icon = "sqlmap";
    type = "Application";
    categories = [ "X-webapp-analysis" ];
  };
  xdg.desktopEntries.evil-winrm = {
    name = "evil-winrm";
    genericName = "";
    exec = "sh -c \"evil-winrm -h;\\${SHELL:-zsh}\"";
    icon = "evil-winrm";
    type = "Application";
    categories = [ "X-maintaining-access" "X-pass-hash" ];
  };
  xdg.desktopEntries.davtest = {
    name = "davtest";
    genericName = "";
    exec = "sh -c \"davtest;\\${SHELL:-zsh}\"";
    icon = "davtest";
    type = "Application";
    categories = [ "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.reaver = {
    name = "reaver";
    genericName = "";
    exec = "sh -c \"reaver -h;\\${SHELL:-zsh}\"";
    icon = "reaver";
    type = "Application";
    categories = [ "X-wireless-attacks" ];
  };
  xdg.desktopEntries.backdoor-factory = {
    name = "backdoor-factory";
    genericName = "";
    exec = "sh -c \"backdoor-factory -h;\\${SHELL:-zsh}\"";
    icon = "backdoor-factory";
    type = "Application";
    categories = [ "X-maintaining-access" "X-social-engineering-tools" ];
  };
  xdg.desktopEntries.metasploit_framework_1 = {
    name = "metasploit framework";
    genericName = "";
    exec = "sh -c \"sudo msfdb init && msfconsole;\\${SHELL:-zsh}\"";
    icon = "metasploit-framework";
    type = "Application";
    categories = [ "X-exploitation-tools" ];
  };
  xdg.desktopEntries.pdfid = {
    name = "pdfid";
    genericName = "";
    exec = "sh -c \"pdfid -h;\\${SHELL:-zsh}\"";
    icon = "pdfid";
    type = "Application";
    categories = [ "X-pdf-forensics-tools" ];
  };
  xdg.desktopEntries.wafw00f = {
    name = "wafw00f";
    genericName = "";
    exec = "sh -c \"wafw00f -h;\\${SHELL:-zsh}\"";
    icon = "wafw00f";
    type = "Application";
    categories = [ "X-ids-ips-identification" ];
  };
  xdg.desktopEntries.crunch = {
    name = "crunch";
    genericName = "";
    exec = "sh -c \"crunch;\\${SHELL:-zsh}\"";
    icon = "crunch";
    type = "Application";
    categories = [ "X-password-attacks" "X-profile" ];
  };
  xdg.desktopEntries.proxychains4 = {
    name = "proxychains4";
    genericName = "";
    exec = "sh -c \"proxychains4;\\${SHELL:-zsh}\"";
    icon = "proxychains";
    type = "Application";
    categories = [ "tunneling" "X-maintaining-access" ];
  };
  xdg.desktopEntries.nmap = {
    name = "nmap";
    genericName = "";
    exec = "sh -c \"nmap;\\${SHELL:-zsh}\"";
    icon = "nmap";
    type = "Application";
    categories = [ "X-info-gathering" "X-network-scanners" "X-vulnerability-analysis" ];
  };
  xdg.desktopEntries.ffuf = {
    name = "ffuf";
    genericName = "";
    exec = "sh -c \"ffuf -h;\\${SHELL:-zsh}\"";
    icon = "ffuf";
    type = "Application";
    categories = [ "X-web-crawlers" ];
  };
  xdg.desktopEntries.joomscan = {
    name = "joomscan";
    genericName = "";
    exec = "sh -c \"joomscan;\\${SHELL:-zsh}\"";
    icon = "/usr/share/icons/MagicArch/MagicArch_Logo_32px.png";
    type = "Application";
    categories = [ "X-cms-identification" "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.nikto = {
    name = "nikto";
    genericName = "";
    exec = "sh -c \"nikto -h;\\${SHELL:-zsh}\"";
    icon = "nikto";
    type = "Application";
    categories = [ "X-vulnerability-analysis" "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.responder = {
    name = "responder";
    genericName = "";
    exec = "sh -c \"responder -h;\\${SHELL:-zsh}\"";
    icon = "responder";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.htop = {
    name = "Htop";
    genericName = "Process Viewer";
    exec = "htop";
    icon = "htop";
    type = "Application";
    categories = [ "X-System" "X-Monitor" "X-ConsoleOnly" ];
  };




  ## .directory application category entries
  xdg.desktopEntries.digital_forensics_directory = {
    name = "Digital Forensics";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.network_sniffers_directory = {
    name = "Network Sniffers";
    genericName = "";
    type = "Directory";
    icon = "kali-sniffing-spoofing-trans";
  };
  xdg.desktopEntries.software_defined_radio_directory = {
    name = "Software Defined Radio";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
  };
  xdg.desktopEntries.exploitation_tools_directory = {
    name = "Exploitation Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-exploitation-tools-trans";
  };
  xdg.desktopEntries.pdf_forensics_tools_directory = {
    name = "PDF Forensics Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.gvm_directory = {
    name = "GVM";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.stress_testing_directory = {
    name = "Stress Testing";
    genericName = "";
    type = "Directory";
    icon = "kali-stress-testing-trans";
  };
  xdg.desktopEntries.beef_directory = {
    name = "BeEF";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.defectdojo_directory = {
    name = "Defectdojo";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.openvas_scanner_directory = {
    name = "OpenVAS Scanner";
    genericName = "";
    type = "Directory";
    icon = "kali-vuln-assessment-trans";
  };
  xdg.desktopEntries.forensic_analysis_tools_directory = {
    name = "Forensic Analysis Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.detect_directory = {
    name = "Detect";
    genericName = "";
    type = "Directory";
    icon = "kali-detect-trans";
  };
  xdg.desktopEntries.web_crawlers_directory_bruteforce_directory = {
    name = "Web Crawlers & Directory Bruteforce";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
  };
  xdg.desktopEntries.dradis_directory = {
    name = "Dradis";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.live_host_identification_directory = {
    name = "Live Host Identification";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
  };
  xdg.desktopEntries.network_forensics_directory = {
    name = "Network Forensics";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.forensics_directory = {
    name = "Forensics";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.network_port_scanners_directory = {
    name = "Network & Port Scanners";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
  };
  xdg.desktopEntries.cms_framework_identification_directory = {
    name = "CMS & Framework Identification";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
  };
  xdg.desktopEntries.password_profiling_wordlists_directory = {
    name = "Password Profiling & Wordlists";
    genericName = "";
    type = "Directory";
    icon = "kali-password-attacks-trans";
  };
  xdg.desktopEntries.radius_directory = {
    name = "Radius";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.system_services_directory = {
    name = "System Services";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.usual_applications_directory = {
    name = "Usual Applications";
    genericName = "";
    type = "Directory";
    icon = "applications-other";
  };
  xdg.desktopEntries.metasploit_directory = {
    name = "Metasploit";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.forensic_imaging_tools_directory = {
    name = "Forensic Imaging Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.social_engineering_tools_directory = {
    name = "Social Engineering Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-social-engineering-trans";
  };
  xdg.desktopEntries.reverse_engineering_directory = {
    name = "Reverse Engineering";
    genericName = "";
    type = "Directory";
    icon = "kali-reverse-engineering-trans";
  };
  xdg.desktopEntries.reporting_tools_directory = {
    name = "Reporting Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-reporting-tools-trans";
  };
  xdg.desktopEntries.web_backdoors_directory = {
    name = "Web Backdoors";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
  };
  xdg.desktopEntries.pcscd_directory = {
    name = "PCSCD";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.gpsd_directory = {
    name = "GPSd";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.web_vulnerability_scanners_directory = {
    name = "Web Vulnerability Scanners";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
  };
  xdg.desktopEntries.wireless_tools_directory = {
    name = "802.11 Wireless Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
  };
  xdg.desktopEntries.tunneling_exfiltration_directory = {
    name = "Tunneling & Exfiltration";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
  };
  xdg.desktopEntries.sniffing_spoofing_directory = {
    name = "Sniffing & Spoofing";
    genericName = "";
    type = "Directory";
    icon = "kali-sniffing-spoofing-trans";
  };
  xdg.desktopEntries.post_exploitation_directory = {
    name = "Post Exploitation";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
  };
  xdg.desktopEntries.respond_directory = {
    name = "Respond";
    genericName = "";
    type = "Directory";
    icon = "kali-respond-trans";
  };
  xdg.desktopEntries.openvas_directory = {
    name = "OpenVAS";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.recover_directory = {
    name = "Recover";
    genericName = "";
    type = "Directory";
    icon = "kali-recover-trans";
  };
  xdg.desktopEntries.nessus_scanner_directory = {
    name = "Nessus Scanner";
    genericName = "";
    type = "Directory";
    icon = "kali-vuln-assessment-trans";
  };
  xdg.desktopEntries.other_wireless_tools_directory = {
    name = "Other Wireless Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
  };
  xdg.desktopEntries.faraday_directory = {
    name = "Faraday";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.protect_directory = {
    name = "Protect";
    genericName = "";
    type = "Directory";
    icon = "kali-protect-trans";
  };
  xdg.desktopEntries.metasploit_framework_directory = {
    name = "Metasploit Framework";
    genericName = "";
    type = "Directory";
    icon = "kali-metasploit";
  };
  xdg.desktopEntries.database_assessment_directory = {
    name = "Database Assessment";
    genericName = "";
    type = "Directory";
    icon = "kali-database-assessment-trans";
  };
  xdg.desktopEntries.mysql_directory = {
    name = "MySQL";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.web_application_proxies_directory = {
    name = "Web Application Proxies";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
  };
  xdg.desktopEntries.spoofing_mitm_directory = {
    name = "Spoofing & MITM";
    genericName = "";
    type = "Directory";
    icon = "kali-sniffing-spoofing-trans";
  };
  xdg.desktopEntries.sleuth_kit_suite_directory = {
    name = "Sleuth Kit Suite";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.xplico_directory = {
    name = "Xplico";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.http_directory = {
    name = "HTTP";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.wireless_attacks_directory = {
    name = "Wireless Attacks";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
  };
  xdg.desktopEntries.dns_analysis_directory = {
    name = "DNS Analysis";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
  };
  xdg.desktopEntries.ssh_directory = {
    name = "SSH";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
  };
  xdg.desktopEntries.ids_ips_identification_directory = {
    name = "IDS/IPS Identification";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
  };
  xdg.desktopEntries.identify_directory = {
    name = "Identify";
    genericName = "";
    type = "Directory";
    icon = "kali-identify-trans";
  };
  xdg.desktopEntries.os_backdoors_directory = {
    name = "OS Backdoors";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
  };
  xdg.desktopEntries.rfid_nfc_tools_directory = {
    name = "RFID & NFC Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
  };
  xdg.desktopEntries.passing_the_hash_tools_directory = {
    name = "Passing the Hash Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-password-attacks-trans";
  };
  xdg.desktopEntries.forensic_carving_tools_directory = {
    name = "Forensic Carving Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
  };
  xdg.desktopEntries.command_control_directory = {
    name = "Command & Control";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
  };
  
  xdg.desktopEntries.information_gathering_directory = {
    name = "Information Gathering";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.dns_analysis = {
    name = "DNS Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.smtp_analysis_directory = {
    name = "SMTP Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.osint_analysis_directory = {
    name = "OSINT Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.smb_analysis_directory = {
    name = "SMB Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.route_analysis_directory = {
    name = "Route Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.host_identification = {
    name = "Host Identification";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.ssl_analysis_directory = {
    name = "SSL Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.firewall_tools = {
    name = "Firewall Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.snmp_analysis_directory = {
    name = "SNMP Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.network_and_port_scanners = {
    name = "Network and Port Scanners";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.vulnerability_analysis_directory = {
    name = "Vulnerability Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.cisco_tools_directory = {
    name = "Cisco Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.fuzzing_tools_directory = {
    name = "Fuzzing Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.voip_tools_directory = {
    name = "VoIP Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.nessus_directory = {
    name = "Nessus";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.openvas = {
    name = "OpenVAS";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.stress_testin_directory = {
    name = "Stress Testing";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.web_application_analysis_directory = {
    name = "Web Application Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.cms_and_site_identification = {
    name = "CMS and Site Identification";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.web_crawlers = {
    name = "Web Crawlers";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.webapp_proxies = {
    name = "WebApp Proxies";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.web_vulnerability_scanners = {
    name = "Web Vulnerability Scanners";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.database_assessment = {
    name = "Database Assessment";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.password_attacks_directory = {
    name = "Password Attacks";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.online_attacks_directory = {
    name = "Online Attacks";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.offline_attacks_directory = {
    name = "Offline Attacks";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.passing_the_hash = {
    name = "Passing the Hash";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.password_profiling = {
    name = "Password Profiling";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.wireless_attacks = {
    name = "Wireless Attacks";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.wireless_analysis = {
    name = "802.11 Wireless Analysis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.bluetooth_tools_directory = {
    name = "Bluetooth Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.software_defined_radio = {
    name = "Software Defined Radio";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.rfid_nfc_tools = {
    name = "RFID NFC Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.other_wireless_tools = {
    name = "Other Wireless Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.reverse_engineering = {
    name = "Reverse Engineering";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.exploit_frameworks = {
    name = "Exploit Frameworks";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.sniffing_-_spoofing = {
    name = "Sniffing - Spoofing";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.network_sniffers = {
    name = "Network Sniffers";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.network_spoofing = {
    name = "Network Spoofing";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.maintaining_access = {
    name = "Maintaining Access";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.os_backdoors = {
    name = "OS Backdoors";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.web_backdoors = {
    name = "Web Backdoors";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.command_and_control = {
    name = "Command and Control";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.tunneling = {
    name = "Tunneling";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.forensic_tools = {
    name = "Forensic Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.pdf_forensics_tools = {
    name = "PDF Forensics Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.forensics_analysis_suites = {
    name = "Forensics Analysis Suites";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.digital_forensics = {
    name = "Digital Forensics";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.forensic_carving_tools = {
    name = "Forensic Carving Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.forensic_imaging_tools = {
    name = "Forensic Imaging Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.forensic_hashing_tools = {
    name = "Forensic Hashing Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.reporting_tools = {
    name = "Reporting Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.social_engineering_tools = {
    name = "Social Engineering Tools";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.system_services = {
    name = "System Services";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.beef_xss_framework = {
    name = "BEEF XSS Framework";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.metasploit = {
    name = "Metasploit";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.dradis = {
    name = "Dradis";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.xplico = {
    name = "Xplico";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.gvm = {
    name = "GVM";
    genericName = "";
    type = "Directory";
  };
  xdg.desktopEntries.defectdojo = {
    name = "Defectdojo";
    genericName = "";
    type = "Directory";
  };
  
}