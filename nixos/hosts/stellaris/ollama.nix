# https://wiki.nixos.org/wiki/Ollama
{ pkgs
, ...
}:
{
  # Enable Ollama with CUDA acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # Explicitly use NVIDIA RTX 5070 Ti for inference
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      # 8-bit KV cache (needs flash attention): about half the context memory, so
      # larger models and contexts stay in the 12 GB of VRAM.
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
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
