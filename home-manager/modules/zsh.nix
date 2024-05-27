{ pkgs, ... }:

{
    programs.zsh = {
       enable = true;
       enableAutosuggestions.enable = true;
       syntaxHighlighting.enable = true;
       shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
      };
    };
    
    programs.oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
            "git"
            "npm"
            "history"
            "node"
            "rust"
            "deno"
        ];
    };
};