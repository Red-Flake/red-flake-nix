{ pkgs, ... }:

{
    programs.zsh = {

       enable = true;
       enableCompletion = true;
       autosuggestions.enable = true;
       syntaxHighlighting.enable = true;
       shellAliases = {
            ll = "ls -l";
            update = "sudo nixos-rebuild switch";
       };

        oh-my-zsh = {
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

}