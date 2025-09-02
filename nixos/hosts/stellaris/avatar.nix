{ 
  config,
  pkgs,
  user,
  ... }:

let
  # Define the username
  username = "${user}";

  # Define the Gravatar URL
  url = "https://2.gravatar.com/avatar/c891e0a6799055b534073decbd5254cd0552d9c748edff94bc7529b703047868?size=512&d=initials";

  # Fetch the avatar image into the Nix store
  avatar = pkgs.fetchurl {
    url = url;
    sha256 = "sha256-r8Fb/otwo6I+9oOhKTC71r32gC9d1cH90/aH1sW1GPE=";  # See instructions below to get the hash
  };
in
{
  # Enable AccountsService (required for KDE to read the avatar)
  services.accounts-daemon.enable = true;

  # Declaratively set up the avatar and user configuration
  systemd.tmpfiles.rules = [
    # Ensure the icons directory exists
    "d /var/lib/AccountsService/icons 0755 root root -"
    # Place the avatar image in the correct location
    "f /var/lib/AccountsService/icons/${username} 0644 root root - ${avatar}"
    # Ensure the users directory exists
    "d /var/lib/AccountsService/users 0755 root root -"
    # Create a user configuration file pointing to the avatar
    "f /var/lib/AccountsService/users/${username} 0644 root root - \"[User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n\""
  ];
}