{
  allowBroken = true;

  # Ecrypts to ecrypt user home folder
  security.pam.enableEcryptfs = true;
  permittedInsecurePackages = [
    "nix-2.15.3"
  ];
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
