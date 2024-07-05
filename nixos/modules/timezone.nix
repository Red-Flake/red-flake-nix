{
  config,
  pkgs,
  lib,
  ...
}: let
  timezone = "Europe/Berlin";
in {
  # Set your time zone.
  time.timeZone = "${timezone}";
}
