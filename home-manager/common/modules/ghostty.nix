# Common firefox configuration
{ ...
}:
{
  # Import from existing user modules where this is already configured
  imports = [
    ../../pascal/modules/ghostty.nix
  ];
}
