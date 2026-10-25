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
    pkgsUnstable.rea-agents # REA MCP server + CLI (needs unstable's Node)
  ];
}
