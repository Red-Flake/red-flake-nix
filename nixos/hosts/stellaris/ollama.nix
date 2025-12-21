# https://wiki.nixos.org/wiki/Ollama
{ config
, lib
, pkgs
, inputs
, user
, ...
}:
{
  # Enable Ollama with CUDA acceleration
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    # Optional: preload models
    # loadModels = [ "llama3.2:3b" ];
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
