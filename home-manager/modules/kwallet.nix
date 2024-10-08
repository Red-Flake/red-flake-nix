{ config, lib, pkgs, ... }:
{
  # deploy konsole profile
  home.file.".config/kwalletrc" = {
    force = true;
    text = ''
      [Wallet]
      Close When Idle=false
      Close on Screensaver=false
      Default Wallet=kdewallet
      Enabled=false
      First Use=false
      Idle Timeout=10
      Launch Manager=false
      Leave Manager Open=false
      Leave Open=true
      Prompt on Open=false
      Use One Wallet=true

      [org.freedesktop.secrets]
      apiEnabled=false
    '';
  };
}
