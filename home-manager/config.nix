{
  allowBroken = true;

  # Ecrypts to ecrypt user home folder
  security.pam.enableEcryptfs = true;
  permittedInsecurePackages = [
    "nix-2.15.3"
  ];
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/1c080b79c4751030f07aac7f3f94e026241da3ac.tar.gz") {
      inherit pkgs;
    };
  };
}
