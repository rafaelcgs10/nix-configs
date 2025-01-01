sudo nix-channel --add https://github.com/NixOS/nixpkgs/archive/b706aae81110d9fe2027bf4b552d27e1491d5e99.tar.gz nixpkgs-unstable
sudo nix-channel --add https://nixos.org/channels/nixos-24.11 nixos
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
