sudo nix-channel --add https://github.com/NixOS/nixpkgs/archive/9a6aabc4740790ef3bbb246b86d029ccf6759658.tar.gz nixpkgs-unstable
sudo nix-channel --add https://github.com/NixOS/nixpkgs/archive/a575c243c23e2851b78c00e9fa245232926ec32f.tar.gz nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/15ecadd9fef467f14461cab9e8e37ebd2d3f4a3b.tar.gz home-manager
sudo nix-channel --update
cachix use nix-community

mkdir -p ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/home.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/config.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/imports/raspberry-pi-4/default.nix ~/nix-configs/home-manager/imports/

home-manager switch
