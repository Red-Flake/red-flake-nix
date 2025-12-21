{ ...
}:
{
  programs.nixcord = {
    enable = true;
    discord.enable = false;
    vesktop.enable = true;
    config = {
      themeLinks = [
        "https://raw.githubusercontent.com/refact0r/system24/refs/heads/main/theme/flavors/system24-catppuccin-mocha.theme.css"
      ];
      plugins = {
        # Spotify Tweaks
        spotifyControls = {
          enable = true;
          useSpotifyUris = true;
        };
        spotifyCrack.enable = true;
        spotifyShareCommands.enable = true;
        fixSpotifyEmbeds.enable = true;
        openInApp.enable = true; # Enables Spotify URIs

        # General Tweaks
        alwaysTrust.enable = true; # Removes the annoying untrusted domain and suspicious file popup
        betterSessions.enable = true; # Enhances the sessions (devices) menu
        betterUploadButton.enable = true; # Upload with a single click, open menu with right click
        biggerStreamPreview.enable = true; # Allows enlarging stream previews
        copyFileContents.enable = true; # Adds a button to text file attachments to copy their contents
        fixYoutubeEmbeds.enable = true; # Bypasses youtube videos being blocked from display on Discord
        nsfwGateBypass.enable = true; # Allows you to access NSFW channels without setting/verifying your age

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
}
