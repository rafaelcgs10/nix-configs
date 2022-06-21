sudo nix-channel --add https://channels.nixos.org/nixpkgs-unstable/ nixpkgs-unstable
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
sudo nix-channel --update

sudo mkdir -p /mnt/etc/nixos

sudo cp ./nixos/configuration.nix /mnt/etc/nixos
sudo cp ./nixos/virtual-box/hardware-configuration.nix /mnt/etc/nixos
sudo cp ./nixos/virtual-box/boot-loader.nix /mnt/etc/nixos

sudo nixos-install
