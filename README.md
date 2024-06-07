# red-flake-nix
Red-Flake Nix flake

<br>

## Install (as root)

<br>

### clone the repo

<br>

first clone the repo into /root
```bash
nix-shell -p git
```
```bash
git clone https://github.com/Red-Flake/red-flake-nix /root/red-flake-nix
```

<br>

### hardware-configuration

<br>

then copy your system's `hardware-configuration.nix` into the `nixos` folder
```bash
cp /etc/nixos/hardware-configuration.nix /root/red-flake-nix/nixos/
```

if you don't have a hardware-configuration already, you can generate a new one like so:
```bash
nixos-generate-config
```
the above command will generate a new hardware-configuration for you and save it to `/etc/nixos/hardware-configuration.nix`

<br>

### installation

<br>

finally install the flake
```bash
nixos-rebuild switch --flake '/root/red-flake-nix#redflake'
```