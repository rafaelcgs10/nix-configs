# Nix Configurations

This repository root is the flake. Use `/home/rafael/nix-configs#<host>` for system builds.

The NixOS host outputs embed Home Manager for `rafael`, so `nixos-rebuild switch` applies both system and user configuration.

## Hosts

| Flake output | Machine |
| --- | --- |
| `thinkpad` | Alias for `thinkpad-e14` |
| `thinkpad-e14` | ThinkPad E14 |
| `bbtablet` | Surface Go tablet |
| `bbstation` | BBStation desktop |

## Switch This Machine

On the ThinkPad, use:

```sh
sudo nixos-rebuild switch --flake /home/rafael/nix-configs#thinkpad
```

Equivalent explicit host name:

```sh
sudo nixos-rebuild switch --flake /home/rafael/nix-configs#thinkpad-e14
```

Other machines:

```sh
sudo nixos-rebuild switch --flake /home/rafael/nix-configs#bbtablet
sudo nixos-rebuild switch --flake /home/rafael/nix-configs#bbstation
```

## Build Without Switching

```sh
nix build /home/rafael/nix-configs#nixosConfigurations.thinkpad.config.system.build.toplevel
```

Dry-run the build plan:

```sh
nix build --dry-run /home/rafael/nix-configs#nixosConfigurations.thinkpad.config.system.build.toplevel
```

## Home Manager Only

Normally this is not needed because Home Manager is embedded in the NixOS outputs. For a user-only switch:

```sh
home-manager switch --flake /home/rafael/nix-configs#rafael@thinkpad
```

## Notes

Pure flake evaluation only sees files tracked by Git or staged in the Git index. If a referenced file is new, add it to Git before building.

The warning `Git tree '/home/rafael/nix-configs' is dirty` means the build includes uncommitted or staged changes.
