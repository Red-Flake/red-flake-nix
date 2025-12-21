{ config
, lib
, pkgs
, ...
}:

{
  home.activation.flatpak = lib.mkAfter ''
    # Check if we can resolve dl.flathub.org
    if ping -c 3 dl.flathub.org &> /dev/null; then
      # Add flathub repo if the address is resolvable
      ${lib.getExe' pkgs.flatpak "flatpak"} remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    else
      echo "dl.flathub.org cannot be resolved. Skipping the addition of the Flathub repository."
    fi
  '';
}
