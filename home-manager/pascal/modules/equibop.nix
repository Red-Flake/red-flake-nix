{ lib
, pkgs
, ...
}:
{
  programs.nixcord = {
    enable = lib.mkDefault true;

    # Disable Discord and Vencord to use Equibop instead
    discord = {
      enable = lib.mkForce false;
      vencord.enable = lib.mkForce false;
    };

    # Enable and configure Equibop
    equibop = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.equibop;
      autoscroll.enable = true;
    };

    # Disable arRPC (Discord RPC compatibility bridge).
    # This is written to `~/.config/equibop/settings/settings.json`.
    equibopConfig.arRPC = "off";

    # Reduce background/theme overhead (no themes in use).
    equibopConfig.enableOnlineThemes = false;
    equibopConfig.useQuickCss = false;
    equibopConfig.useQuickCSS = false;

    config = {
      #themeLinks = [
      #  "https://capnkitten.github.io/BetterDiscord/Themes/Material-Discord/css/source.css"
      #];
      plugins = {
        # General Tweaks
        alwaysTrust.enable = true; # Removes the annoying untrusted domain and suspicious file popup
        betterSessions.enable = true; # Enhances the sessions (devices) menu
        #betterUploadButton.enable = true; # Upload with a single click, open menu with right click
        biggerStreamPreview.enable = true; # Allows enlarging stream previews
        copyFileContents.enable = true; # Adds a button to text file attachments to copy their contents
        fixYoutubeEmbeds.enable = true; # Bypasses youtube videos being blocked from display on Discord
        # NOTE: nixcord removed the nsfwGateBypass plugin option in the pinned revision.
        #nsfwGateBypass.enable = true; # Allows you to access NSFW channels without setting/verifying your age
        #PinDMs.enable = true; # Allows you to pin DMs, making them appear at the top of your DMs/ServerList
        NoRPC.enable = true; # Disable Discord's RPC server

        # Image Tweaks
        fixImagesQuality.enable = true; # Improves quality of images in chat by forcing png format.
        #imageFilename.enable = true; # Displays the file name of images & GIFs as a tooltip when hovering over them
        imageZoom.enable = true; # zoom in to images and gifs
        #reverseImageSearch.enable = true; # Adds ImageSearch to image context menus

        # Premium Features
        fakeNitro.enable = true; # Enables Stickers, and 4k streams
        volumeBooster.enable = true; # Allows you to set the user and stream volume above the default maximum
        webScreenShareFixes.enable = true; # Removes 2500kbps bitrate cap on chromium and vesktop clients
        youtubeAdblock.enable = true; # Block ads in YouTube embeds and the WatchTogether activity via AdGuard
      };
    };
  };
}
