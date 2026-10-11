# https://wiki.nixos.org/wiki/Ollama
{ pkgs
, ...
}:
{
  # Enable Ollama with CUDA acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # Explicitly use NVIDIA RTX 5070 Ti for inference
  };

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
