{ config
, lib
, pkgs
, ...
}:
let
  nixcordEnabled = config.programs.nixcord.enable;
  vesktopEnabled = nixcordEnabled && config.programs.nixcord.vesktop.enable;
  myColors = {
    base00 = "1e1e2e"; # background
    base05 = "cdd6f4"; # default fg
  };
in
{
  programs.nixcord = {
    enable = lib.mkDefault true;

    # Disable Discord and Vencord to use Vesktop instead
    discord = {
      enable = lib.mkForce false;
      vencord.enable = lib.mkForce false;
    };

    # Enable and configure Vesktop
    vesktop = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.vesktop;
      autoscroll.enable = true;
      settings = {
        minimizeToTray = "on";
        discordBranch = "stable";
        arRPC = "on";
        splashColor = "#${myColors.base05}";
        splashBackground = "#${myColors.base00}";
        splashTheming = true;
        checkUpdates = false;
        disableMinSize = true;
        tray = true;
        hardwareAcceleration = true;
        firstLaunch = false;
      };
    };

    config = {
      #themeLinks = [
      #  "https://capnkitten.github.io/BetterDiscord/Themes/Material-Discord/css/source.css"
      #];
      plugins = {
        # General Tweaks
        alwaysTrust.enable = true; # Removes the annoying untrusted domain and suspicious file popup
        betterSessions.enable = true; # Enhances the sessions (devices) menu
        betterUploadButton.enable = true; # Upload with a single click, open menu with right click
        biggerStreamPreview.enable = true; # Allows enlarging stream previews
        copyFileContents.enable = true; # Adds a button to text file attachments to copy their contents
        fixYoutubeEmbeds.enable = true; # Bypasses youtube videos being blocked from display on Discord
        #nsfwGateBypass.enable = true; # Allows you to access NSFW channels without setting/verifying your age
        #pinDMs.enable = true; # Allows you to pin DMs, making them appear at the top of your DMs/ServerList

        # Image Tweaks
        #fixImagesQuality.enable = true; # Improves quality of images in chat by forcing png format.
        imageFilename.enable = true; # Displays the file name of images & GIFs as a tooltip when hovering over them
        imageZoom.enable = true; # zoom in to images and gifs
        reverseImageSearch.enable = true; # Adds ImageSearch to image context menus

        # Premium Features
        fakeNitro.enable = true; # Enables Stickers, and 4k streams
        volumeBooster.enable = true; # Allows you to set the user and stream volume above the default maximum
        webScreenShareFixes.enable = true; # Removes 2500kbps bitrate cap on chromium and vesktop clients
        youtubeAdblock.enable = true; # Block ads in YouTube embeds and the WatchTogether activity via AdGuard
      };
    };
  };

  # INFO: Create vesktop initial state to ignore "firstLaunch" configuration.
  # After that let vesktop manage its own state.
  home.activation.create-vesktop-initial-state = lib.mkIf vesktopEnabled (
    let
      vesktopConfigDir = config.xdg.configHome + "/vesktop";
      vesktopStateDir = config.xdg.stateHome + "/vesktop";
      vesktopStateFile = vesktopStateDir + "/state.json";
    in
    lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      set -eu
      if [ ! -f "${vesktopStateFile}" ]; then
        # Ensure both dirs exist
        install -d -m 700 "${vesktopConfigDir}" "${vesktopStateDir}"
        # Write atomically
        printf '%s\n' '{"firstLaunch":false}' > "${vesktopStateFile}.tmp"
        mv -f "${vesktopStateFile}.tmp" "${vesktopStateFile}"
      fi
    ''
  );
}
