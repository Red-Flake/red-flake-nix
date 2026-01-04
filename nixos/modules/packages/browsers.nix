{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox-bin
    # Disable buggy Wayland color management that causes bright/oversaturated colors
    # on wide-gamut displays with Intel Mesa Xe driver
    # See: https://community.brave.app/t/washed-out-colors-when-hardware-acceleration-is-enabled/643668
    (ungoogled-chromium.override {
      commandLineArgs = [
        "--disable-features=WaylandWpColorManagerV1"
      ];
    })
    tor-browser
  ];
}
