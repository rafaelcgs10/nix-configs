sudo nix-channel --add https://channels.nixos.org/nixpkgs-unstable/ nixpkgs-unstable
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
sudo nix-channel --update
cachix use nix-community

mkdir -p ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/home.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/config.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/imports/raspberry-pi-4/default.nix ~/nix-configs/home-manager/imports/

home-manager switch
