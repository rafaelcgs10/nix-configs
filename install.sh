sudo nix-channel --add https://github.com/NixOS/nixpkgs/archive/5a0711127cd8b916c3d3128f473388c8c79df0da.tar.gz nixpkgs-unstable
sudo nix-channel --add https://github.com/NixOS/nixpkgs/archive/2baa12ff69913392faf0ace833bc54bba297ea95.tar.gz nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/613691f285dad87694c2ba1c9e6298d04736292d.tar.gz home-manager
sudo nix-channel --update
cachix use nix-community

sudo mv /etc/nixos/configuration.nix ./nixos/configuration.nix_bk
sudo mv /etc/nixos/hardware-configuration.nix ./nixos/hardware-configuration.nix_bk

sudo ln -s ~/nix-configs/nixos/configuration.nix /etc/nixos

sudo nixos-rebuild switch

mkdir -p ~/.config/home-manager
ln -s ~/nix-configs/home-manager/home.nix ~/.config/home-manager
ln -s ~/nix-configs/home-manager/config.nix ~/.config/home-manager
ln -s ~/nix-configs/home-manager/imports/default/default.nix ~/nix-configs/home-manager/imports/

home-manager switch
