{
  allowBroken = true;

  # Ecrypts to ecrypt user home folder
  security.pam.enableEcryptfs = true;
  permittedInsecurePackages = [
    "nix-2.15.3"
  ];
}
