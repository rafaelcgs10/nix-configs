# Secrets (agenix)

Secrets live here **encrypted** (`*.age`) and are safe to commit. They are
decrypted at activation into `/run/agenix/<name>` (tmpfs, root-only), using each
machine's own SSH **host** key — so nothing has to be copied to a machine by
hand.

Recipients are declared in `secrets.nix`. Every secret also lists the user key
`rafael`, which is the recovery path: without it, losing every machine would
make these files permanently undecryptable.

## Everyday use

```sh
cd secrets
agenix -e smb-secrets.age        # edit (opens $EDITOR); no prompt
git commit -am "rotate smb credentials" && git push
sudo nixos-rebuild switch --flake ~/nix-configs#thinkpad
```

Create a secret from an existing file without ever printing it:

```sh
cat /path/to/plaintext | agenix -e new-secret.age
```

## Adding a machine

```sh
ssh-keyscan -t ed25519 HOST          # or: cat /etc/ssh/ssh_host_ed25519_key.pub
# add the key to secrets.nix (both the `let` block and the secret's list), then:
agenix --rekey                       # run from a machine that can already decrypt
git commit -am "add HOST" && git push
```

Only then add `./nixos/agenix.nix` to that host in `flake.nix` — a host that is
not a recipient cannot decrypt, and its activation will fail.

## Status

| Secret | Used by | Hosts wired up |
|---|---|---|
| `smb-secrets.age` | CIFS mounts of `//192.168.0.104` | thinkpad-e14 only |

`bbstation` and `bbtablet` still read `/home/rafael/.smb-secrets` directly; they
were unreachable when this was set up. To migrate them: add their host keys as
above, `agenix --rekey`, import `./nixos/agenix.nix`, and change their
`credentials=` path to `/run/agenix/smb-secrets`.

## Still to migrate

- `/home/rafael/cf-api-token` (Cloudflare DDNS on the Raspberry Pi)
- `users.users.rafael.password` in `nixos/configuration.nix` — currently
  **plaintext in a public repo**; should become `hashedPasswordFile` backed by a
  secret here. Rotate the password itself regardless: it is already in the
  public git history and cannot be un-published.
- `config.adminpassFile` in the Raspberry Pi Nextcloud config (`writeText` puts
  it world-readable in the nix store).

## Reverting

Everything here is additive: drop the `./nixos/agenix.nix` import, restore the
`credentials=` path to `/home/rafael/.smb-secrets`, and the previous behaviour
is back. The plaintext file on each machine was left in place on purpose.
