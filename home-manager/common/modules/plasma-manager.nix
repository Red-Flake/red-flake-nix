# Common plasma-manager configuration
{ ...
}:
{
  # Import from existing user modules where this is already configured
  imports = [
    ../../pascal/modules/plasma-manager.nix
  ];
}
