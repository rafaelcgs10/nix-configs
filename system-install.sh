sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz home-manager
sudo nix-channel --update
sudo mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/etc
sudo cp -r ~/nix-configs/nixos/ /mnt/etc/
sudo nixos-install
