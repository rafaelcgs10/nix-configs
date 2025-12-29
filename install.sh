sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable
sudo nix-channel --add https://nixos.org/channels/nixos-25.11 nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
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
