sudo nix-channel --add https://channels.nixos.org/nixpkgs-unstable/ nixpkgs-unstable
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
sudo nix-channel --update

sudo rm /etc/nixos/configuration.nix
sudo ln -s /home/rafael/nix-configs/nixos/configuration.nix /etc/nixos/
cp /etc/nixos/hardware-configuration.nix /home/rafael/nix-configs/nixos/
sudo rm /etc/nixos/hardware-configuration.nix
sudo nixos-rebuild switch

mkdir -p /home/rafael/.config/nixpkgs
ln -s /home/rafael/nix-configs/home-manager/home.nix /home/rafael/.config/nixpkgs
ln -s /home/rafael/nix-configs/home-manager/config.nix /home/rafael/.config/nixpkgs
home-manager switch
