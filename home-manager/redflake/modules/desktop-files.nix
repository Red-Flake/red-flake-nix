{ config
, lib
, pkgs
, ...
}:

{

  ## .directory application category entries
  xdg.desktopEntries.digital_forensics_directory = {
    name = "Digital Forensics";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.network_sniffers_directory = {
    name = "Network Sniffers";
    genericName = "";
    type = "Directory";
    icon = "kali-sniffing-spoofing-trans";
    terminal = null;
  };
  xdg.desktopEntries.software_defined_radio_directory = {
    name = "Software Defined Radio";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
    terminal = null;
  };
  xdg.desktopEntries.exploitation_tools_directory = {
    name = "Exploitation Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-exploitation-tools-trans";
    terminal = null;
  };
  xdg.desktopEntries.pdf_forensics_tools_directory = {
    name = "PDF Forensics Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.gvm_directory = {
    name = "GVM";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.stress_testing_directory = {
    name = "Stress Testing";
    genericName = "";
    type = "Directory";
    icon = "kali-stress-testing-trans";
    terminal = null;
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
    terminal = null;
  };
  xdg.desktopEntries.openvas_scanner_directory = {
    name = "OpenVAS Scanner";
    genericName = "";
    type = "Directory";
    icon = "kali-vuln-assessment-trans";
    terminal = null;
  };
  xdg.desktopEntries.forensic_analysis_tools_directory = {
    name = "Forensic Analysis Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.detect_directory = {
    name = "Detect";
    genericName = "";
    type = "Directory";
    icon = "kali-detect-trans";
    terminal = null;
  };
  xdg.desktopEntries.web_crawlers_directory_bruteforce_directory = {
    name = "Web Crawlers & Directory Bruteforce";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
    terminal = null;
  };
  xdg.desktopEntries.dradis_directory = {
    name = "Dradis";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.live_host_identification_directory = {
    name = "Live Host Identification";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
    terminal = null;
  };
  xdg.desktopEntries.network_forensics_directory = {
    name = "Network Forensics";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.forensics_directory = {
    name = "Forensics";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.network_port_scanners_directory = {
    name = "Network & Port Scanners";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
    terminal = null;
  };
  xdg.desktopEntries.cms_framework_identification_directory = {
    name = "CMS & Framework Identification";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
    terminal = null;
  };
  xdg.desktopEntries.password_profiling_wordlists_directory = {
    name = "Password Profiling & Wordlists";
    genericName = "";
    type = "Directory";
    icon = "kali-password-attacks-trans";
    terminal = null;
  };
  xdg.desktopEntries.radius_directory = {
    name = "Radius";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.system_services_directory = {
    name = "System Services";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.usual_applications_directory = {
    name = "Usual Applications";
    genericName = "";
    type = "Directory";
    icon = "applications-other";
    terminal = null;
  };
  xdg.desktopEntries.metasploit_directory = {
    name = "Metasploit";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.forensic_imaging_tools_directory = {
    name = "Forensic Imaging Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.social_engineering_tools_directory = {
    name = "Social Engineering Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-social-engineering-trans";
    terminal = null;
  };
  xdg.desktopEntries.X-reverse_engineering = {
    name = "X-reverse_engineering";
    genericName = "";
    type = "Directory";
    icon = "kali-social-engineering-trans";
    terminal = null;
  };
  xdg.desktopEntries.reporting_tools_directory = {
    name = "Reporting Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-reporting-tools-trans";
    terminal = null;
  };
  xdg.desktopEntries.web_backdoors_directory = {
    name = "Web Backdoors";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
    terminal = null;
  };
  xdg.desktopEntries.pcscd_directory = {
    name = "PCSCD";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.gpsd_directory = {
    name = "GPSd";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.web_vulnerability_scanners_directory = {
    name = "Web Vulnerability Scanners";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
    terminal = null;
  };
  xdg.desktopEntries.wireless_tools_directory = {
    name = "802.11 Wireless Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
    terminal = null;
  };
  xdg.desktopEntries.tunneling_exfiltration_directory = {
    name = "Tunneling & Exfiltration";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
    terminal = null;
  };
  xdg.desktopEntries.sniffing_spoofing_directory = {
    name = "Sniffing & Spoofing";
    genericName = "";
    type = "Directory";
    icon = "kali-sniffing-spoofing-trans";
    terminal = null;
  };
  xdg.desktopEntries.post_exploitation_directory = {
    name = "Post Exploitation";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
    terminal = null;
  };
  xdg.desktopEntries.respond_directory = {
    name = "Respond";
    genericName = "";
    type = "Directory";
    icon = "kali-respond-trans";
    terminal = null;
  };
  xdg.desktopEntries.openvas_directory = {
    name = "OpenVAS";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.recover_directory = {
    name = "Recover";
    genericName = "";
    type = "Directory";
    icon = "kali-recover-trans";
    terminal = null;
  };
  xdg.desktopEntries.nessus_scanner_directory = {
    name = "Nessus Scanner";
    genericName = "";
    type = "Directory";
    icon = "kali-vuln-assessment-trans";
    terminal = null;
  };
  xdg.desktopEntries.other_wireless_tools_directory = {
    name = "Other Wireless Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
    terminal = null;
  };
  xdg.desktopEntries.faraday_directory = {
    name = "Faraday";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.protect_directory = {
    name = "Protect";
    genericName = "";
    type = "Directory";
    icon = "kali-protect-trans";
    terminal = null;
  };
  xdg.desktopEntries.metasploit_framework_directory = {
    name = "Metasploit Framework";
    genericName = "";
    type = "Directory";
    icon = "kali-metasploit";
    terminal = null;
  };
  xdg.desktopEntries.database_assessment_directory = {
    name = "Database Assessment";
    genericName = "";
    type = "Directory";
    icon = "kali-database-assessment-trans";
    terminal = null;
  };
  xdg.desktopEntries.mysql_directory = {
    name = "MySQL";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.web_application_proxies_directory = {
    name = "Web Application Proxies";
    genericName = "";
    type = "Directory";
    icon = "kali-web-application-trans";
    terminal = null;
  };
  xdg.desktopEntries.spoofing_mitm_directory = {
    name = "Spoofing & MITM";
    genericName = "";
    type = "Directory";
    icon = "kali-sniffing-spoofing-trans";
    terminal = null;
  };
  xdg.desktopEntries.sleuth_kit_suite_directory = {
    name = "Sleuth Kit Suite";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.xplico_directory = {
    name = "Xplico";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.http_directory = {
    name = "HTTP";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.wireless_attacks_directory = {
    name = "Wireless Attacks";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
    terminal = null;
  };
  xdg.desktopEntries.dns_analysis_directory = {
    name = "DNS Analysis";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
    terminal = null;
  };
  xdg.desktopEntries.ssh_directory = {
    name = "SSH";
    genericName = "";
    type = "Directory";
    icon = "kali-system-services-trans";
    terminal = null;
  };
  xdg.desktopEntries.ids_ips_identification_directory = {
    name = "IDS/IPS Identification";
    genericName = "";
    type = "Directory";
    icon = "kali-info-gathering-trans";
    terminal = null;
  };
  xdg.desktopEntries.identify_directory = {
    name = "Identify";
    genericName = "";
    type = "Directory";
    icon = "kali-identify-trans";
    terminal = null;
  };
  xdg.desktopEntries.os_backdoors_directory = {
    name = "OS Backdoors";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
    terminal = null;
  };
  xdg.desktopEntries.rfid_nfc_tools_directory = {
    name = "RFID & NFC Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-wireless-attacks-trans";
    terminal = null;
  };
  xdg.desktopEntries.passing_the_hash_tools_directory = {
    name = "Passing the Hash Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-password-attacks-trans";
    terminal = null;
  };
  xdg.desktopEntries.forensic_carving_tools_directory = {
    name = "Forensic Carving Tools";
    genericName = "";
    type = "Directory";
    icon = "kali-forensics-trans";
    terminal = null;
  };
  xdg.desktopEntries.command_control_directory = {
    name = "Command & Control";
    genericName = "";
    type = "Directory";
    icon = "kali-maintaining-access-trans";
    terminal = null;
  };

  xdg.desktopEntries.information_gathering_directory = {
    name = "Information Gathering";
    genericName = "";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/binwalk.svg";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.dns_analysis = {
    name = "DNS Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.smtp_analysis_directory = {
    name = "SMTP Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.osint_analysis_directory = {
    name = "OSINT Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.smb_analysis_directory = {
    name = "SMB Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.route_analysis_directory = {
    name = "Route Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.host_identification = {
    name = "Host Identification";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.ssl_analysis_directory = {
    name = "SSL Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.firewall_tools = {
    name = "Firewall Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.snmp_analysis_directory = {
    name = "SNMP Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.network_and_port_scanners = {
    name = "Network and Port Scanners";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.vulnerability_analysis_directory = {
    name = "Vulnerability Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.cisco_tools_directory = {
    name = "Cisco Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.fuzzing_tools_directory = {
    name = "Fuzzing Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.voip_tools_directory = {
    name = "VoIP Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.nessus_directory = {
    name = "Nessus";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.openvas = {
    name = "OpenVAS";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.stress_testin_directory = {
    name = "Stress Testing";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.web_application_analysis_directory = {
    name = "Web Application Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.cms_and_site_identification = {
    name = "CMS and Site Identification";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.web_crawlers = {
    name = "Web Crawlers";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.webapp_proxies = {
    name = "WebApp Proxies";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.web_vulnerability_scanners = {
    name = "Web Vulnerability Scanners";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.database_assessment = {
    name = "Database Assessment";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.password_attacks_directory = {
    name = "Password Attacks";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.online_attacks_directory = {
    name = "Online Attacks";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.offline_attacks_directory = {
    name = "Offline Attacks";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.passing_the_hash = {
    name = "Passing the Hash";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.password_profiling = {
    name = "Password Profiling";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.wireless_attacks = {
    name = "Wireless Attacks";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.wireless_analysis = {
    name = "802.11 Wireless Analysis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.bluetooth_tools_directory = {
    name = "Bluetooth Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.software_defined_radio = {
    name = "Software Defined Radio";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.rfid_nfc_tools = {
    name = "RFID NFC Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.other_wireless_tools = {
    name = "Other Wireless Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.exploit_frameworks = {
    name = "Exploit Frameworks";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.sniffing_-_spoofing = {
    name = "Sniffing - Spoofing";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.network_sniffers = {
    name = "Network Sniffers";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.network_spoofing = {
    name = "Network Spoofing";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.maintaining_access = {
    name = "Maintaining Access";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.os_backdoors = {
    name = "OS Backdoors";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.web_backdoors = {
    name = "Web Backdoors";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.command_and_control = {
    name = "Command and Control";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.tunneling = {
    name = "Tunneling";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.forensic_tools = {
    name = "Forensic Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.pdf_forensics_tools = {
    name = "PDF Forensics Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.forensics_analysis_suites = {
    name = "Forensics Analysis Suites";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.digital_forensics = {
    name = "Digital Forensics";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.forensic_carving_tools = {
    name = "Forensic Carving Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.forensic_imaging_tools = {
    name = "Forensic Imaging Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.forensic_hashing_tools = {
    name = "Forensic Hashing Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.reporting_tools = {
    name = "Reporting Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.social_engineering_tools = {
    name = "Social Engineering Tools";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.system_services = {
    name = "System Services";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.beef_xss_framework = {
    name = "BEEF XSS Framework";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.metasploit = {
    name = "Metasploit";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.dradis = {
    name = "Dradis";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.xplico = {
    name = "Xplico";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.gvm = {
    name = "GVM";
    genericName = "";
    type = "Directory";
    terminal = null;
  };
  xdg.desktopEntries.defectdojo = {
    name = "Defectdojo";
    genericName = "";
    type = "Directory";
    terminal = null;
  };

  ## .desktop application entries
  # fix vscode StartupWMClass so that it groups properly in taskbar
  xdg.desktopEntries."code" = {
    name = "Visual Studio Code";
    genericName = "Text Editor";
    exec = "code %F";
    icon = "code";
    type = "Application";
    categories = [
      "Utility"
      "TextEditor"
      "Development"
      "IDE"
    ];
    startupNotify = true;
    settings = {
      StartupWMClass = "code"; # fixes duplicate taskbar entry
    };
  };

  xdg.desktopEntries.ghidra = {
    name = "ghidra";
    genericName = "";
    exec = "ghidra";
    icon = "ghidra";
    type = "Application";
    categories = [ "X-reverse_engineering" ];
  };
  xdg.desktopEntries.binwalk = {
    name = "binwalk";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"binwalk -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/binwalk.svg";
    type = "Application";
    categories = [ "X-forensics" ];
  };
  xdg.desktopEntries.tcpdump = {
    name = "tcpdump";
    genericName = "Network Traffic Analyzer";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"tcpdump -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/tcpdump.svg";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.bpython = {
    name = "bpython";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"bpython\"";
    icon = "bpython";
    type = "Application";
    categories = [ "X-Development" ];
  };
  xdg.desktopEntries.sqlmap = {
    name = "sqlmap";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"sqlmap --wizard && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/sqlmap.svg";
    type = "Application";
    categories = [ "X-database-assessment" ];
  };
  xdg.desktopEntries.macchanger = {
    name = "macchanger";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"macchanger --help && zsh\"";
    icon = "macchanger";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.aircrack-ng = {
    name = "aircrack-ng";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"aircrack-ng --help && zsh\"";
    icon = "aircrack-ng";
    type = "Application";
    categories = [ "X-wireless-attacks" ];
  };
  xdg.desktopEntries.beef_start = {
    name = "beef start";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"sudo beef\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/beef-xss.svg";
    type = "Application";
    categories = [ "X-beef-service" ];
  };
  xdg.desktopEntries.ollydbg = {
    name = "ollydbg";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"ollydbg --help && zsh\"";
    icon = "ollydbg";
    type = "Application";
    categories = [ "X-reverse_engineering" ];
  };
  xdg.desktopEntries.cewl = {
    name = "cewl";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"cewl --help && zsh\"";
    icon = "cewl";
    type = "Application";
    categories = [ "X-password-attacks" ];
  };
  xdg.desktopEntries.pdf-parser = {
    name = "pdf-parser";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"pdf-parser --help && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/pdf-parser.svg";
    type = "Application";
    categories = [ "X-pdf-forensics-tools" ];
  };
  xdg.desktopEntries.hash-identifier = {
    name = "hash-identifier";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"hash-identifier && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/hash-identifier.svg";
    type = "Application";
    categories = [ "X-offline-attacks" ];
  };
  xdg.desktopEntries.commix = {
    name = "commix";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"commix --help && zsh\"";
    icon = "commix";
    type = "Application";
    categories = [ "X-webapp-analysis" ];
  };
  xdg.desktopEntries.netexec = {
    name = "netexec";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"netexec --help && zsh\"";
    icon = "${config.home.homeDirectory}/.local/share/icons/red-flake/netexec.png";
    type = "Application";
    categories = [ "X-exploitation-tools" ];
  };
  xdg.desktopEntries.john = {
    name = "john";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"john --help && zsh\"";
    icon = "john";
    type = "Application";
    categories = [ "X-password-attacks" ];
  };
  xdg.desktopEntries.ncrack = {
    name = "ncrack";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"ncrack --help && zsh\"";
    icon = "ncrack";
    type = "Application";
    categories = [ "X-password-attacks" ];
  };
  xdg.desktopEntries.bettercap = {
    name = "bettercap";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"bettercap --help && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/bettercap.svg";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.veil = {
    name = "veil";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"veil -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/veil.svg";
    type = "Application";
    categories = [ "X-maintaining-access" ];
  };
  xdg.desktopEntries.onesixtyone = {
    name = "onesixtyone";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"onesixtyone && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/onesixtyone.svg";
    type = "Application";
    categories = [ "X-snmp-analysis" ];
  };
  xdg.desktopEntries.foremost = {
    name = "foremost";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"foremost -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/foremost.svg";
    type = "Application";
    categories = [ "X-forensics" ];
  };
  xdg.desktopEntries.impacket = {
    name = "impacket";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"ls --color=auto ${pkgs.python312Packages.impacket}/bin/ && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/impacket.svg";
    type = "Application";
    categories = [ "X-maintaining-access" ];
  };
  xdg.desktopEntries.powershell = {
    name = "PowerShell";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"pwsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/pwsh.svg";
    type = "Application";
    categories = [ "X-Utility" ];
  };
  xdg.desktopEntries.hydra = {
    name = "hydra";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"hydra | grep --color=auto '^\|Supported services:'; hydra-wizard.sh && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/hydra.svg";
    type = "Application";
    categories = [ "X-password-attacks" ];
  };
  xdg.desktopEntries.radare2 = {
    name = "radare2";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"radare2 -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/radare2.svg";
    type = "Application";
    categories = [ "X-reverse_engineering" ];
  };
  xdg.desktopEntries.apktool = {
    name = "apktool";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"apktool && zsh\"";
    icon = "apktool";
    type = "Application";
    categories = [ "X-android-attacks" ];
  };
  xdg.desktopEntries.wifite = {
    name = "wifite";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"wifite --help && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/wifite.svg";
    type = "Application";
    categories = [ "X-wireless-attacks" ];
  };
  xdg.desktopEntries.vim = {
    name = "Vim";
    genericName = "Text Editor";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"vim %F && zsh\"";
    icon = "gvim";
    type = "Application";
    categories = [ "X-TextEditor" ];
  };
  xdg.desktopEntries.whatweb = {
    name = "whatweb";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"whatweb -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/whatweb.svg";
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
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"patator.py -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/patator.svg";
    type = "Application";
    categories = [ "X-online-attacks" ];
  };
  xdg.desktopEntries.btopPlusPlus = {
    name = "btop++";
    genericName = "System Monitor";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"btop && zsh\"";
    icon = "btop";
    type = "Application";
    categories = [ "X-System" ];
  };
  xdg.desktopEntries.wpscan = {
    name = "wpscan";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"wpscan --help && zsh\"";
    icon = "wpscan";
    type = "Application";
    categories = [ "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.social_engineering_toolkit = {
    name = "social engineering toolkit (root)";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"sudo setoolkit && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/set.svg";
    type = "Application";
    categories = [ "X-social-engineering-tools" ];
  };
  xdg.desktopEntries.smbmap = {
    name = "smbmap";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"smbmap -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/smbmap.svg";
    type = "Application";
    categories = [ "X-smb-analysis" ];
  };
  xdg.desktopEntries.hashcat = {
    name = "hashcat";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"hashcat --help && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/hashcat.svg";
    type = "Application";
    categories = [ "X-password-attacks" ];
  };
  xdg.desktopEntries.httrack = {
    name = "httrack";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"httrack -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/httrack.svg";
    type = "Application";
    categories = [ "X-webapp-analysis" ];
  };
  xdg.desktopEntries.evil-winrm = {
    name = "evil-winrm";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"evil-winrm -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/evil-winrm.svg";
    type = "Application";
    categories = [ "X-maintaining-access" ];
  };
  xdg.desktopEntries.davtest = {
    name = "davtest";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"davtest.pl && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/davtest.svg";
    type = "Application";
    categories = [ "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.reaver = {
    name = "reaver";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"sudo reaver -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/reaver.svg";
    type = "Application";
    categories = [ "X-wireless-attacks" ];
  };
  xdg.desktopEntries.backdoor-factory = {
    name = "backdoor-factory";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"backdoor-factory -h && zsh\"";
    icon = "backdoor-factory";
    type = "Application";
    categories = [ "X-maintaining-access" ];
  };
  xdg.desktopEntries.metasploit_framework_1 = {
    name = "metasploit framework";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"msfconsole && zsh\"";
    icon = "metasploit-framework";
    type = "Application";
    categories = [ "X-exploitation-tools" ];
  };
  xdg.desktopEntries.pdfid = {
    name = "pdfid";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"pdfid -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/pdfid.svg";
    type = "Application";
    categories = [ "X-pdf-forensics-tools" ];
  };
  xdg.desktopEntries.wafw00f = {
    name = "wafw00f";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"wafw00f -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/wafw00f.svg";
    type = "Application";
    categories = [ "X-ids-ips-identification" ];
  };
  xdg.desktopEntries.crunch = {
    name = "crunch";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"crunch && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/crunch.svg";
    type = "Application";
    categories = [ "X-password-attacks" ];
  };
  xdg.desktopEntries.proxychains4 = {
    name = "proxychains4";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"proxychains4 && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/proxychains.svg";
    type = "Application";
    categories = [ "X-tunneling" ];
  };
  xdg.desktopEntries.nmap = {
    name = "nmap";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"nmap && zsh\"";
    icon = "nmap";
    type = "Application";
    categories = [ "X-info-gathering" ];
  };
  xdg.desktopEntries.ffuf = {
    name = "ffuf";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"ffuf -h && zsh\"";
    icon = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark/apps/scalable/ffuf.svg";
    type = "Application";
    categories = [ "X-web-crawlers" ];
  };
  xdg.desktopEntries.joomscan = {
    name = "joomscan";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"joomscan.pl && zsh\"";
    icon = "${config.home.homeDirectory}/.red-flake/artwork/logos/RedFlake_Logo_32x32px.png";
    type = "Application";
    categories = [ "X-cms-identification" ];
  };
  xdg.desktopEntries.nikto = {
    name = "nikto";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"nikto -h && zsh\"";
    icon = "nikto";
    type = "Application";
    categories = [ "X-web-vulnerability-scanners" ];
  };
  xdg.desktopEntries.responder = {
    name = "responder";
    genericName = "";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"responder -h && zsh\"";
    icon = "responder";
    type = "Application";
    categories = [ "X-sniffing-spoofing" ];
  };
  xdg.desktopEntries.htop = {
    name = "Htop";
    genericName = "Process Viewer";
    exec = "/run/current-system/sw/bin/konsole --profile red-flake --noclose -e /run/current-system/sw/bin/zsh -c \"htop && zsh\"";
    icon = "htop";
    type = "Application";
    categories = [ "X-System" ];
  };

}
