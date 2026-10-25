{ config
, lib
, pkgs
, ...
}:
let
  equibopEnabled = config.programs.nixcord.enable && config.programs.nixcord.equibop.enable;
  equibopConfigDir = config.programs.nixcord.equibop.configDir;
  equicordSettingsFile = "${equibopConfigDir}/settings/settings.json";
  initialEquibopState = pkgs.writeText "equibop-state.json" (builtins.toJSON {
    firstLaunch = false;
  });
  initialEquibopSettings = pkgs.writeText "equibop-settings.json" (builtins.toJSON {
    discordBranch = "stable";
    minimizeToTray = true;
    # Rich Presence off: don't start the bundled arRPC server (an extra
    # process that also scans running processes to detect games)
    arRPC = false;
    arRPCDisabled = true;
    splashColor = "rgb(212, 213, 216)";
    splashBackground = "rgb(0, 0, 0)";
    enableSplashScreen = false;
    splashTheming = false;
    hardwareVideoAcceleration = true;
    clickTrayToShowHide = true;
    trayMainOverride = false;
    spellCheckLanguages = [ "en-US" "en" ];
  });
in
{
  imports = [ ../../shared/writable-files.nix ];

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
        noRpc.enable = true; # Disable Discord's RPC server

        # Image Tweaks
        fixImagesQuality.enable = true; # Improves quality of images in chat by forcing png format.
        #imageFilename.enable = true; # Displays the file name of images & GIFs as a tooltip when hovering over them
        imageZoom.enable = true; # zoom in to images and gifs
        #reverseImageSearch.enable = true; # Adds ImageSearch to image context menus

        # Premium Features
        #fakeNitro.enable = true; # Enables Stickers, and 4k streams
        volumeBooster.enable = true; # Allows you to set the user and stream volume above the default maximum
        webScreenShareFixes.enable = true; # Removes 2500kbps bitrate cap on chromium and vesktop clients
        youtubeAdblock.enable = true; # Block ads in YouTube embeds and the WatchTogether activity via AdGuard
      };
    };
  };

  # INFO: Equibop writes its config at runtime, but nixcord links the Equicord
  # settings (plugins) as a read-only store file, which breaks Equibop.
  # Take that file over from nixcord and keep a writable copy instead, replaced
  # at every login (see writable-files.nix).
  #
  # Equibop's own settings.json and state.json (firstLaunch = false skips the
  # first-launch screen) are only seeded when missing, so Equibop keeps
  # whatever it writes there later.
  home.file = lib.mkIf equibopEnabled {
    ${equicordSettingsFile}.enable = false;
  };

  custom.writableFiles = lib.mkIf equibopEnabled {
    ${equicordSettingsFile} = {
      source = config.home.file.${equicordSettingsFile}.source;
      mode = "0600";
    };
  };

  systemd.user.tmpfiles.rules = lib.mkIf equibopEnabled [
    "d ${equibopConfigDir} 0755 - - -"
    "d ${equibopConfigDir}/settings 0755 - - -"
    "C ${equibopConfigDir}/settings.json 0644 - - - ${initialEquibopSettings}"
    "C ${equibopConfigDir}/state.json 0644 - - - ${initialEquibopState}"
  ];
}
