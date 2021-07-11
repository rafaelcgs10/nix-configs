sudo nix-channel --add https://channels.nixos.org/nixpkgs-unstable/ nixpkgs-unstable
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
sudo nix-channel --update

mkdir -p /home/rafael/.config/nixpkgs
ln -s /home/rafael/nix-configs/home-manager/home.nix /home/rafael/.config/nixpkgs
ln -s /home/rafael/nix-configs/home-manager/config.nix /home/rafael/.config/nixpkgs
ln -s /home/rafael/nix-configs/home-manager/imports/raspberry-pi-4/default.nix /home/rafael/nix-configs/home-manager/imports/

home-manager switch
