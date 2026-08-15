{ pkgs, ... }:

let
  # Synology bundles an xcb-only Qt and copies Nix-patched binaries into HOME.
  # Refresh only that copied payload when its store package changes; keep data.
  synologyDrive = pkgs.synology-drive-client.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postFixup = (old.postFixup or "") + ''
      wrapProgram "$out/bin/synology-drive" \
        --set SYNOLOGY_NIX_PACKAGE "$out" \
        --set QT_QPA_PLATFORM xcb \
        --set QT_STYLE_OVERRIDE Fusion \
        --run '
          state_dir="$HOME/.SynologyDrive"
          marker="$state_dir/.nix-package"
          installed_package=
          if [ -r "$marker" ]; then
            IFS= read -r installed_package < "$marker"
          fi
          if [ "$installed_package" != "$SYNOLOGY_NIX_PACKAGE" ]; then
            ${pkgs.coreutils}/bin/rm -rf "$state_dir/SynologyDrive.app"
            ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
            printf "%s\n" "$SYNOLOGY_NIX_PACKAGE" > "$marker"
          fi
        '
    '';
  });
in
{
  home.packages = [
    # pkgs.spotify
    # pkgs.whatsapp-for-linux
    pkgs.insomnia
    pkgs.telegram-desktop
    pkgs.caprine-bin
    pkgs.obs-studio
    synologyDrive
    # unstable.lutris
    pkgs.tlaplusToolbox
    pkgs.discord
    # pkgs.bitwarden
    # (pkgs.callPackage ../iopaint/default.nix {})
    # (newer_pkgs.qt6Packages.callPackage ../gpt4all.nix {})

    # pkgs.google-cloud-sdk
  ];
}
