{
  config,
  pkgsx86_64_v3,
  lib,
  ...
}: let
  timezone = "Europe/Berlin";
in {
  # Set your time zone.
  time.timeZone = "${timezone}";
}
