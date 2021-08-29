sudo nix-channel --add https://channels.nixos.org/nixpkgs-unstable/ nixpkgs-unstable
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
sudo nix-channel --update
nix-shell -p cachix
sudo cachix use nix-community

mkdir -p ~/.config/nixpkgs
ln -s ~/home-manager/home.nix ~/.config/nixpkgs
ln -s ~/home-manager/config.nix ~/.config/nixpkgs
ln -s ~/home-manager/imports/raspberry-pi-4/default.nix ~/nix-configs/home-manager/imports/

home-manager switch
