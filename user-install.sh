sudo nix-channel --add https://github.com/NixOS/nixpkgs/archive/b706aae81110d9fe2027bf4b552d27e1491d5e99.tar.gz nixpkgs-unstable
sudo nix-channel --add https://nixos.org/channels/nixos-24.11 nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/10e99c43cdf4a0713b4e81d90691d22c6a58bdf2.tar.gz home-manager
sudo nix-channel --update
cachix use nix-community

mkdir -p ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/home.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/config.nix ~/.config/nixpkgs
ln -s ~/nix-configs/home-manager/imports/default/default.nix ~/nix-configs/home-manager/imports/

home-manager switch
