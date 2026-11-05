#!/usr/bin/env bash
# Flash the vovo SD image and install its pre-generated SSH host key, so that
# agenix can decrypt the Wi-Fi password (and Syncthing identity) on first boot.
#
#   nix build .#nixosConfigurations.vovo.config.system.build.sdImage
#   nixos/vovo/prepare-sd.sh /dev/sdX            # whole card, not a partition
#
# The host key lives outside the repo, in ~/.secrets/vovo (never committed).
set -euo pipefail

DEV=${1:-}
IMAGE_DIR=${IMAGE_DIR:-result/sd-image}
KEY_DIR=${KEY_DIR:-$HOME/.secrets/vovo}

die() { echo "error: $*" >&2; exit 1; }

[[ -n $DEV ]] || die "usage: $0 /dev/sdX  (the whole SD card device; see lsblk)"
[[ -b $DEV ]] || die "$DEV is not a block device"
[[ $DEV =~ [0-9]$ && ! $DEV =~ (mmcblk|nvme|loop)[0-9]+$ ]] && die "$DEV looks like a partition; pass the whole device"
[[ $(lsblk -dno TYPE "$DEV") == disk ]] || die "$DEV is not a whole disk"
[[ -f $KEY_DIR/ssh_host_ed25519_key ]] || die "missing $KEY_DIR/ssh_host_ed25519_key"

# Refuse anything holding a mounted system filesystem.
if lsblk -nro MOUNTPOINT "$DEV" | grep -qxE '/|/boot|/nix|/home|/nix/store'; then
  die "$DEV holds a mounted system filesystem; wrong device"
fi

shopt -s nullglob
images=("$IMAGE_DIR"/*.img.zst)
(( ${#images[@]} == 1 )) || die "expected exactly one .img.zst in $IMAGE_DIR (run nix build first)"
IMG=${images[0]}

echo "Image : $IMG"
echo "Target: $DEV"
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS "$DEV"
echo
read -r -p "ALL DATA ON $DEV WILL BE ERASED. Type the device name ($DEV) to continue: " answer
[[ $answer == "$DEV" ]] || die "aborted"

# Unmount anything the desktop auto-mounted from the card.
for part in $(lsblk -nrpo NAME "$DEV" | tail -n +2); do
  sudo umount "$part" 2>/dev/null || true
done

echo "==> writing image"
zstd -dc "$IMG" | sudo dd of="$DEV" bs=4M conv=fsync status=progress
sudo partprobe "$DEV" 2>/dev/null || true
sudo udevadm settle

ROOT=$(lsblk -nrpo NAME,LABEL "$DEV" | awk '$2 == "NIXOS_SD" { print $1 }')
[[ -n $ROOT ]] || die "could not find the NIXOS_SD partition on $DEV"

MNT=$(mktemp -d)
trap 'sudo umount "$MNT" 2>/dev/null || true; rmdir "$MNT"' EXIT
sudo mount "$ROOT" "$MNT"

echo "==> installing vovo's SSH host key"
sudo install -d -m 0755 -o root -g root "$MNT/etc/ssh"
sudo install -m 0600 -o root -g root "$KEY_DIR/ssh_host_ed25519_key" "$MNT/etc/ssh/ssh_host_ed25519_key"
sudo install -m 0644 -o root -g root "$KEY_DIR/ssh_host_ed25519_key.pub" "$MNT/etc/ssh/ssh_host_ed25519_key.pub"

sudo umount "$MNT"
sync
echo
echo "Done. Put the card in the Pi and power it on; after ~2 minutes:"
echo "  ssh vovo.local"
