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
  vesktopConfigDir = config.programs.nixcord.vesktop.configDir;
  vencordSettingsFile = "${vesktopConfigDir}/settings/settings.json";
  initialVesktopState = pkgs.writeText "vesktop-state.json" (builtins.toJSON {
    firstLaunch = false;
  });
  initialVesktopSettings = pkgs.writeText "vesktop-settings.json" (builtins.toJSON {
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
  });
in
{
  imports = [ ../../shared/writable-files.nix ];

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
    };

    config = {
      plugins = {
        # General Tweaks
        alwaysTrust.enable = true; # Removes the annoying untrusted domain and suspicious file popup
        betterSessions.enable = true; # Enhances the sessions (devices) menu
        betterUploadButton.enable = true; # Upload with a single click, open menu with right click
        biggerStreamPreview.enable = true; # Allows enlarging stream previews
        copyFileContents.enable = true; # Adds a button to text file attachments to copy their contents
        fixYoutubeEmbeds.enable = true; # Bypasses youtube videos being blocked from display on Discord
        # NOTE: nixcord removed the nsfwGateBypass plugin option in the pinned revision.
        #nsfwGateBypass.enable = true; # Allows you to access NSFW channels without setting/verifying your age
        #PinDMs.enable = true; # Allows you to pin DMs, making them appear at the top of your DMs/ServerList

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

  # INFO: Vesktop writes its config at runtime, but nixcord links the Vencord
  # settings (plugins) as a read-only store file, which breaks Vesktop.
  # Take that file over from nixcord and keep a writable copy instead, replaced
  # at every login (see writable-files.nix).
  #
  # Vesktop's own settings.json and state.json (firstLaunch = false skips the
  # first-launch screen) are only seeded when missing, so Vesktop keeps
  # whatever it writes there later.
  home.file = lib.mkIf vesktopEnabled {
    ${vencordSettingsFile}.enable = false;
  };

  custom.writableFiles = lib.mkIf vesktopEnabled {
    ${vencordSettingsFile} = {
      source = config.home.file.${vencordSettingsFile}.source;
      mode = "0600";
    };
  };

  systemd.user.tmpfiles.rules = lib.mkIf vesktopEnabled [
    "d ${vesktopConfigDir} 0700 - - -"
    "d ${vesktopConfigDir}/settings 0700 - - -"
    "C ${vesktopConfigDir}/settings.json 0600 - - - ${initialVesktopSettings}"
    "C ${vesktopConfigDir}/state.json 0600 - - - ${initialVesktopState}"
  ];
}
