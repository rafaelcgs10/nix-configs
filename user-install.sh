sudo nix-channel --add https://github.com/NixOS/nixpkgs/archive/3dcff817eebb7e4afc4e9eae0ce6f722f4d9e399.tar.gz nixpkgs-unstable
sudo nix-channel --add https://nixos.org/channels/nixos-22.11 nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/15ecadd9fef467f14461cab9e8e37ebd2d3f4a3b.tar.gz home-manager
sudo nix-channel --update
cachix use nix-community

mkdir -p ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/home.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/config.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/imports/raspberry-pi-4/default.nix ~/nix-configs/home-manager/imports/

home-manager switch
