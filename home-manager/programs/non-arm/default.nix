{ pkgs, ...}:

{
  home.packages = [
    # pkgs.spotify
    # pkgs.whatsapp-for-linux
    pkgs.insomnia
    pkgs.telegram-desktop
    pkgs.caprine-bin
    pkgs.obs-studio
    pkgs.synology-drive-client
    # unstable.lutris
    pkgs.tlaplusToolbox
    pkgs.discord
    # pkgs.bitwarden
    # (pkgs.callPackage ../iopaint/default.nix {})
    # (newer_pkgs.qt6Packages.callPackage ../gpt4all.nix {})

    # pkgs.google-cloud-sdk
  ];
}
