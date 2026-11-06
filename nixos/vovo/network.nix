{ config, lib, pkgs, ... }:

# Wi-Fi (plain wpa_supplicant, lighter than NetworkManager), SSH, mDNS.
{
  networking.wireless = {
    enable = true;
    # Contains `psk_home=<passphrase>`; decrypted by agenix before services start.
    secretsFile = config.age.secrets.wifi.path;
    networks."PowerpuffPigerne_5G".pskRaw = "ext:psk_home";
    # 5 GHz channels need the right regulatory domain.
    extraConfig = "country=DK";
  };
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=DK";

  # brcmfmac power saving causes multi-second lag and dropped SSH sessions.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save off"
  '';

  # Ethernet (if plugged) and Wi-Fi both via DHCP.
  networking.useDHCP = true;
  # Not the container interfaces: dhcpcd gave podman's veth a 169.254.x.x
  # link-local address (which avahi then announced).
  networking.dhcpcd.denyInterfaces = [ "veth*" "podman*" ];

  # Reachable as vovo.local from the other machines.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    # Only the LAN interfaces: avahi also announced vovo.local on the podman
    # bridge (openWakeWord container), so it sometimes resolved to an
    # unreachable 10.88.x / 169.254.x address (seen on the Pi itself:
    # 169.254.40.226). Wi-Fi, and Ethernet if plugged in.
    allowInterfaces = [ "wlan0" "end0" ];
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    # Only the pre-generated ed25519 key (its public half is pinned in
    # bbstation's known_hosts); no RSA key generated on first boot.
    hostKeys = [
      { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # SSH opens 22 itself; Syncthing opens its own ports (syncthing.nix).
  networking.firewall.enable = true;
}
