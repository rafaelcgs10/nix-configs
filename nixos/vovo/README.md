# vovo: Raspberry Pi 4 music box

Headless NixOS on a Raspberry Pi 4 (2 GB), 32 GB micro SD. Built on bbstation,
never on the Pi.

| What | Where |
|---|---|
| SSH | `ssh vovo.local` (keys only, host key pinned on bbstation) |
| Syncthing UI | http://vovo.local:8384 (user `rafael`, password in `~/.secrets/vovo/syncthing-gui-password` on bbstation) |
| Home Assistant | http://vovo.local:8123 (phase 2) |
| Music Assistant | http://vovo.local:8095 (phase 2) |

## Files

| File | Purpose |
|---|---|
| `default.nix` | users, secrets, nix settings, memory footprint |
| `hardware.nix` | Pi 4 boot (mainline kernel + U-Boot), SD image |
| `network.nix` | Wi-Fi (wpa_supplicant + agenix), SSH, mDNS |
| `audio.nix` | PipeWire (rafael's user session), Bluetooth, Blue Yeti rules |
| `syncthing.nix` | `~/Music`, receive-only from bbstation's `music` folder |
| `syncthing-cert.pem` | vovo's Syncthing certificate (public half) |
| `prepare-sd.sh` | flash the image and install the host key |
| `../../home-manager/profiles/vovo.nix` | slim Home Manager profile |

## Secrets

Pre-generated on bbstation and kept **outside the repo** in `~/.secrets/vovo`:

- `ssh_host_ed25519_key`: vovo's SSH host key. Its public half is an agenix
  recipient in `secrets/secrets.nix`. `prepare-sd.sh` copies it onto the card,
  which is what lets the Pi decrypt the Wi-Fi password on its very first boot.
- `syncthing/`: the Syncthing identity (device ID
  `LYSEQMV-P2BMPYR-FN2HSFF-MOO6DLH-MA35GSG-THZHX7X-4KR2HM6-7ESR4QL`).
- `syncthing-gui-password`

Committed **encrypted** only: `secrets/wifi-vovo.age` (`psk_home=…`),
`secrets/syncthing-vovo-key.age`, `secrets/syncthing-vovo-gui.age`. bbstation's
host key is a recipient, so they can be edited there:

```sh
cd ~/nix-configs/secrets
sudo EDITOR=vim agenix -e wifi-vovo.age -i /etc/ssh/ssh_host_ed25519_key
```

Back up `~/.secrets/vovo`. Losing it only means re-generating the keys and
re-encrypting (the Pi can always be re-flashed), not losing data.

## First install

bbstation needs `boot.binfmt.emulatedSystems = [ "aarch64-linux" ]` (already in
its config). Then:

```sh
cd ~/nix-configs
nix build .#nixosConfigurations.vovo.config.system.build.sdImage
nixos/vovo/prepare-sd.sh /dev/sdX        # whole card; asks for confirmation
```

Boot the Pi; after a couple of minutes `ssh vovo.local` works. The root
partition grows to fill the card on first boot.

## Updating

```sh
nixos-rebuild switch --flake ~/nix-configs#vovo \
  --target-host rafael@vovo.local --sudo
```

bbstation evaluates and builds; only the result is copied to the Pi.

## One-time manual steps

**Pair a Bluetooth speaker** (put the speaker in pairing mode first):

```sh
ssh vovo.local
bluetoothctl
  scan on          # wait for the speaker's MAC
  pair XX:XX:XX:XX:XX:XX
  trust XX:XX:XX:XX:XX:XX
  connect XX:XX:XX:XX:XX:XX
  exit
```

The pairing persists across reboots and rebuilds. When the speaker is on and
connected, WirePlumber routes audio to it; otherwise the 3.5 mm jack is used.

**Check the Blue Yeti**: `lsusb` shows it; `wpctl status` should list it as the
default source and not show its headphone output. Record a test with
`pw-record --rate 16000 --channels 1 /tmp/t.wav` and play it back with
`pw-play /tmp/t.wav`. Set the Yeti's hardware gain knob to about half way.
