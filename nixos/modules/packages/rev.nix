{ pkgs
, pkgsUnstable
, ...
}:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cutter
    cutterPlugins.jsdec
    cutterPlugins.rz-ghidra
    pkgsUnstable.ghidra-bin # REA supports Ghidra 12.1.x only
    jadx
    radare2
    avalonia-ilspy
    binaryninja-free
    # REA MCP server + CLI, wrapped with its optional tools (rea-overlay).
    # Reuse the system's stable Chromium and Wireshark rather than unstable's.
    (pkgsUnstable.rea-agents.override {
      inherit (pkgs) chromium;
      wireshark-cli = pkgs.wireshark;
    })
  ];
}
