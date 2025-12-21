{ pkgs
, user
, ...
}:

let
  # Define the username
  username = "${user}";

  # Define the Gravatar URL
  url = "https://2.gravatar.com/avatar/c891e0a6799055b534073decbd5254cd0552d9c748edff94bc7529b703047868?size=512&d=initials";

  # Fetch the avatar image into the Nix store
  avatar = pkgs.fetchurl {
    url = url;
    sha256 = "sha256-r8Fb/otwo6I+9oOhKTC71r32gC9d1cH90/aH1sW1GPE="; # See instructions below to get the hash
  };
in
{
  # Enable AccountsService (required for KDE to read the avatar)
  services.accounts-daemon.enable = true;

  # Declaratively set the user avatar using a systemd service
  systemd.services.place-user-icon = {
    before = [ "display-manager.service" ];
    wantedBy = [ "display-manager.service" ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
    };

    script = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      pic="${avatar}"

      if [ ! -f "$pic" ]; then
        echo "User image not existing in '$pic' -> Skip setup."
        exit 0
      fi

      echo "User image existing in '$pic' -> Setup."
      cp "$pic" /var/lib/AccountsService/icons/${username}
      echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${username}\n" > /var/lib/AccountsService/users/${username}

      chown root:root /var/lib/AccountsService/users/${username}
      chmod 0600 /var/lib/AccountsService/users/${username}

      chown root:root /var/lib/AccountsService/icons/${username}
      chmod 0444 /var/lib/AccountsService/icons/${username}
    '';
  };
}
