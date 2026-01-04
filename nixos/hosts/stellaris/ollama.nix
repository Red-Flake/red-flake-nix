# https://wiki.nixos.org/wiki/Ollama
{ lib
, user
, ...
}:
{
  # Enable Ollama with CUDA acceleration
  services.ollama = {
    enable = true;
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
