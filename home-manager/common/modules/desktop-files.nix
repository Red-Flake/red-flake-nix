# Common desktop-files configuration
{ ...
}:
{
  # Import from existing user modules where this is already configured
  imports = [
    ../../pascal/modules/desktop-files.nix
  ];
}
