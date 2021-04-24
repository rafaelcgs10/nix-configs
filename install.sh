sudo mkdir -p /mnt/etc/nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz home-manager
sudo nix-channel --update
sudo ln -s /mnt/home/rafael/nix-configs/nixos/configuration.nix /mnt/etc/nixos/
sudo ln -s /mnt/home/rafael/nix-configs/nixos/hardware-configuration.nix /mnt/etc/nixos/
sudo ln -s /mnt/home/rafael/nix-configs/nixos/cachix.nix /mnt/etc/nixos/
sudo nixos-rebuild switch

sudo mkdir -p /mnt/home/rafael/.config/nixpkgs
sudo ln -s /mnt/home/rafael/nix-configs/home-manager/home.nix /mnt/home/rafael/nix-configs/.config/nixpkgs
sudo ln -s /mnt/home/rafael/nix-configs/home-manager/config.nix /mnt/home/rafael/nix-configs/.config/nixpkgs
sudo ln -s /mnt/home/rafael/nix-configs/home-manager/programs /mnt/home/rafael/nix-configs/.config/nixpkgs
