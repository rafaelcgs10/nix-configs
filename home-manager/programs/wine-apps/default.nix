{ pkgs, lib, ... }:

let
  wine = pkgs.wineWow64Packages.waylandFull;

  hdlBatchInstallerVersion = "3.7.0-rev3";

  hdlBatchInstallerFiles = pkgs.stdenv.mkDerivation {
    pname = "hdl-batch-installer-files";
    version = hdlBatchInstallerVersion;

    src = pkgs.fetchurl {
      url = "https://github.com/israpps/HDL-Batch-installer/releases/download/Latest/HDLBInst-x64-v3.7.0-rev3.7z";
      hash = "sha256-wiDHB/oaNOVXPhvazTS4JJjQO/J2nBbHZmgLqhnqDl0=";
    };

    nativeBuildInputs = [ pkgs.p7zip ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      7z x "$src"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/hdl-batch-installer"
      cp -r HDLBInst*/. "$out/share/hdl-batch-installer/"
      runHook postInstall
    '';

    meta = {
      description = "HDL Batch Installer Windows release files";
      homepage = "https://github.com/israpps/HDL-Batch-installer";
      license = lib.licenses.gpl3Only;
      platforms = [ "x86_64-linux" ];
    };
  };

  hdlBatchInstaller = pkgs.writeShellScriptBin "hdl-batch-installer" ''
    set -euo pipefail

    state_root="''${XDG_DATA_HOME:-$HOME/.local/share}/wine-apps/hdl-batch-installer"
    app_dir="$state_root/app"
    prefix="$state_root/prefix"
    version_file="$app_dir/.nix-version"

    if [ ! -f "$version_file" ] || [ "$(${pkgs.coreutils}/bin/cat "$version_file")" != "${hdlBatchInstallerVersion}" ]; then
      ${pkgs.coreutils}/bin/rm -rf "$app_dir"
      ${pkgs.coreutils}/bin/mkdir -p "$app_dir"
      ${pkgs.coreutils}/bin/cp -R "${hdlBatchInstallerFiles}/share/hdl-batch-installer/." "$app_dir/"
      ${pkgs.coreutils}/bin/chmod -R u+w "$app_dir"
      ${pkgs.coreutils}/bin/printf '%s\n' "${hdlBatchInstallerVersion}" > "$version_file"
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$prefix"

    export WINEPREFIX="$prefix"
    export WINEARCH=win64
    export WINEDEBUG="''${WINEDEBUG:--all}"
    unset LD_PRELOAD

    exec ${wine}/bin/wine "$app_dir/HDL-Batch-installer.exe" "$@"
  '';
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
    home.packages = [
      hdlBatchInstaller
      wine
      pkgs.winetricks
    ];

    xdg.desktopEntries.hdl-batch-installer = {
      name = "HDL Batch Installer";
      genericName = "PS2 HDD installer";
      comment = "Run HDL Batch Installer with Wine";
      exec = "${hdlBatchInstaller}/bin/hdl-batch-installer";
      terminal = false;
      type = "Application";
      categories = [ "Game" "Utility" ];
    };

    home.file.".local/share/applications/hdl-batch-installer.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Version=1.5
      Name=HDL Batch Installer
      GenericName=PS2 HDD installer
      Comment=Run HDL Batch Installer with Wine
      Exec=${hdlBatchInstaller}/bin/hdl-batch-installer
      Terminal=false
      Categories=Game;Utility;
    '';
  };
}
