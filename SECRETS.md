# Secrets

Secrets are encrypted with [sops](https://github.com/getsops/sops) and
decrypted at boot by [sops-nix](https://github.com/Mic92/sops-nix). Only
encrypted files are committed; nothing in this repo is readable without one of
the keys below.

## Keys

Every secrets file is encrypted to all keys listed for it in `.sops.yaml`. Any
one of them can decrypt it.

| Key                 | Where it lives                                                  | Used for                              |
| ------------------- | --------------------------------------------------------------- | ------------------------------------- |
| `pascal_fido2`      | YubiKey (FIDO2 + PIN). No identity file.                        | Editing secrets, re-keying hosts      |
| `pascal_passphrase` | `secrets/keys/pascal-passphrase.age`, encrypted with passphrase | Same, when the YubiKey isn't at hand  |
| `host_stellaris`    | The machine's SSH host key in `/persist/etc/ssh/`               | Automatic decryption at boot          |

Decrypted secrets land in `/run/secrets/<name>` (tmpfs, never on disk).

## Unlocking

sops needs to be told which admin key to use:

```sh
# YubiKey: asks for the FIDO2 PIN, then a touch
export SOPS_AGE_KEY=AGE-PLUGIN-FIDO2-HMAC-1VE5KGMEJ945X6CTRM2TF76

# Passphrase
export SOPS_AGE_KEY_FILE=secrets/keys/pascal-passphrase.age
```

The `AGE-PLUGIN-FIDO2-HMAC-…` string is the plugin's fixed "magic" identity
(`age-plugin-fido2-hmac -m`). It's the same for everyone and not secret; the
actual credential is stored inside each encrypted file.

## Editing a secret

```sh
sops secrets/stellaris.yaml
```

This opens the decrypted file in `$EDITOR` and re-encrypts it on save. Add or
change `name: value` lines, then commit.

To use a new secret in Nix, declare it in `nixos/hosts/<host>/secrets.nix`:

```nix
sops.secrets.my-secret.owner = "pascal";
```

and read it from `/run/secrets/my-secret` (or `config.sops.secrets.my-secret.path`).

## After reinstalling a host

A fresh install generates a new SSH host key, so the host can't decrypt its
secrets until it's re-keyed. Services that need secrets fail until then.

1. Get the new host's age recipient:
   ```sh
   ssh-to-age < /persist/etc/ssh/ssh_host_ed25519_key.pub
   ```
2. Replace the host's entry in `.sops.yaml` (e.g. `&host_stellaris`).
3. Unlock with the YubiKey or passphrase (see above) and re-encrypt:
   ```sh
   sops updatekeys secrets/stellaris.yaml
   ```
4. Commit and `nixos-rebuild switch`.

## Adding a new host

Same as above, but add a new `&host_<name>` key, a `creation_rules` entry for
`secrets/<name>.yaml`, and import `inputs.sops-nix.nixosModules.sops` in that
host's config.

## Losing keys

- **YubiKey lost or reset:** unlock with the passphrase, generate a new FIDO2
  recipient (`age-plugin-fido2-hmac -g`, answer `n` to "separate identity"),
  replace `pascal_fido2` in `.sops.yaml`, run `sops updatekeys` on every file.
- **Passphrase forgotten:** same, using the YubiKey, and create a new
  passphrase key with `age-keygen | age -p -a -o secrets/keys/pascal-passphrase.age`.
- **Both lost:** the encrypted files are unrecoverable. Reset the affected
  passwords at their services and create new secrets files.
