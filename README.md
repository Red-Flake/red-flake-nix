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

then enter the directory
```bash
cd /root/red-flake-nix
```

<br>

### hardware-configuration

<br>

then copy your system's `hardware-configuration.nix` into the `nixos` folder
```bash
cp /etc/nixos/hardware-configuration.nix /root/red-flake-nix/nixos/
```

After you copied `hardware-configuration.nix` into the `nixos` folder you need to track it by Git because otherwise it cannot be built using the flake.
```bash
git add --intent-to-add /root/red-flake-nix/nixos/hardware-configuration.nix
```

```bash
git update-index --assume-unchanged /root/red-flake-nix/nixos/hardware-configuration.nix
```

<br>

### installation

<br>

finally install the flake
```bash
nixos-rebuild switch --flake '/root/red-flake-nix#redflake'
```
