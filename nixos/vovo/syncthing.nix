{ config, lib, pkgs, ... }:

# ~/Music, received from bbstation's "music" folder.
#
# vovo's Syncthing identity is pre-generated (public cert here, private key in
# agenix), so its device ID is fixed and already known to bbstation:
#   LYSEQMV-P2BMPYR-FN2HSFF-MOO6DLH-MA35GSG-THZHX7X-4KR2HM6-7ESR4QL
{
  services.syncthing = {
    enable = true;
    user = "rafael";
    group = "users";
    dataDir = "/home/rafael";
    configDir = "/home/rafael/.config/syncthing";

    cert = "${./syncthing-cert.pem}";
    key = config.age.secrets.syncthing-key.path;

    # Web UI for the LAN: http://vovo.local:8384, user `rafael`, password in
    # secrets/syncthing-vovo-gui.age (plain copy: ~/.secrets/vovo on bbstation).
    guiAddress = "0.0.0.0:8384";
    guiPasswordFile = config.age.secrets.syncthing-gui.path;
    openDefaultPorts = true; # 22000/tcp+udp (sync), 21027/udp (discovery)

    # Devices and folders exist only as declared here.
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      gui.user = "rafael";
      options = {
        urAccepted = -1; # no usage reporting prompt
        relaysEnabled = false; # LAN only; bbstation is on the same network
      };
      devices.bbstation.id = "F5KJW5J-QFXVQC5-IMRBM45-DAR62MD-UTWJ4CK-NUPDZLG-ZT3B2IT-KIW6UQG";
      folders.music = {
        id = "sy4td-goyyi"; # must match bbstation's folder ID
        label = "music";
        path = "/home/rafael/Music";
        devices = [ "bbstation" ];
        # Nothing done on the Pi is ever sent back to bbstation.
        type = "receiveonly";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  # Don't let a first full scan of the library starve the voice pipeline.
  systemd.services.syncthing.serviceConfig = {
    Nice = 10;
    IOSchedulingClass = "idle";
    MemoryHigh = "200M";
  };
}
