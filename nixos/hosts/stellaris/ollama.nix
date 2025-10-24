# https://wiki.nixos.org/wiki/Ollama

{
  config,
  lib,
  pkgs,
  inputs,
  user,
  ...
}:
{
  # Enable Ollama with CUDA acceleration
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  # Use the offload wrapper by absolute path + relax sandbox enough to see /dev/nvidia*
  systemd.services.ollama.serviceConfig = {
    ExecStart = lib.mkForce ''
      /run/current-system/sw/bin/nvidia-offload ${pkgs.ollama-cuda}/bin/ollama serve
    '';
    SupplementaryGroups = [
      "video"
      "render"
    ];
    PrivateDevices = false;
    DeviceAllow = [
      "/dev/nvidiactl"
      "/dev/nvidia0"
      "/dev/nvidia-uvm"
      "/dev/dri/renderD*"
    ];
  };

  # Add ollama to system packages
  environment.systemPackages = [ pkgs.ollama ];

  # Add user to ollama group
  users.users.${user}.extraGroups = lib.mkAfter [ "ollama" ];
  users.groups.ollama.members = lib.mkAfter [ user ];

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
