# https://wiki.nixos.org/wiki/Ollama
{ lib
, pkgs
, user
, ...
}:
{
  # Enable Ollama with CUDA acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # Explicitly use NVIDIA RTX 5070 Ti for inference
  };

  # Add user to ollama group
  users.users.${user}.extraGroups = lib.mkAfter [ "ollama" ];

  # Persist /var/lib/private/ollama
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/ollama";
      user = "ollama";
      group = "ollama";
      mode = "0750";
    }
  ];
}
