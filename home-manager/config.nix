{
  allowBroken = true;

  permittedInsecurePackages = [
    "electron-39.8.10"
    "nix-2.15.3"
  ];
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/2a7b28ecbab41224e27a5d491b01cd42c226af1d.tar.gz") {
      inherit pkgs;
    };
  };
}
