# Shared nixpkgs configuration used across all package sets
{
  allowUnfree = true;
  allowInsecurePredicate = _x: true;
  allowInsecure = true;
  # Fallback: explicit list in case allowInsecure doesn't work everywhere
  permittedInsecurePackages = [
    "python-2.7.18.8"
    "python-2.7.18.12"
    "openssl-1.1.1w"
    "electron-39.8.10"
  ];
}
