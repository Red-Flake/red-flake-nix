programs.zsh = {
   enable = true;
   shellAliases = {
    ll = "ls -l";
    update = "sudo nixos-rebuild switch";
  };
};

programs.oh-my-zsh = {
    enable = true;
    plugins = [ ];
    theme = "agnoster";
};