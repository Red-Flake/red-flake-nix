{ config, lib, pkgs, ... }: {
    home.file.".config/bloodhound/config.json".force = true;
    home.file.".config/bloodhound/config.json".source = ./bloodhound/config.json;
}