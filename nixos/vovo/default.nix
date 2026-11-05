{ config, lib, pkgs, inputs, ... }:

# vovo: Raspberry Pi 4 (2 GB) headless music box.
#
# Built with `common = false` in flake.nix: none of the desktop plumbing from
# nixos/configuration.nix is here. Everything is chosen to keep RAM and SD-card
# use low. See ./README.md for building the SD image, flashing and deploying.
{
  imports = [
    inputs.agenix.nixosModules.default
    ./hardware.nix
    ./network.nix
    ./audio.nix
    ./syncthing.nix
    ./home-assistant.nix
    ./music.nix
    ./voice.nix
    ./youtube.nix
  ];

  networking.hostName = "vovo";
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- secrets ----------------------------------------------------------------
  # Decrypted with the pre-generated host key that prepare-sd.sh copies onto the
  # card, so they are available on the very first boot (Wi-Fi needs one).
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    # wpa_supplicant runs as its own unprivileged user, not root.
    wifi = {
      file = ../../secrets/wifi-vovo.age;
      owner = "wpa_supplicant";
      group = "wpa_supplicant";
    };
    # yescrypt hash for console login (plain copy: ~/.secrets/vovo on bbstation).
    rafael-password.file = ../../secrets/rafael-password-vovo.age;
    # Copied into ~/.config/syncthing by syncthing's own (root) ExecStartPre.
    syncthing-key.file = ../../secrets/syncthing-vovo-key.age;
    # Hashed by syncthing-init, which runs as rafael.
    syncthing-gui = {
      file = ../../secrets/syncthing-vovo-gui.age;
      owner = "rafael";
    };
  };

  # --- users ------------------------------------------------------------------
  # SSH is key-only. The password exists only for logging in on a local
  # screen + keyboard when the network is down. sudo needs no password.
  users.mutableUsers = false;
  users.users.rafael = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.rafael-password.path;
    extraGroups = [ "wheel" "audio" ];
    shell = pkgs.zsh;
    # Start rafael's systemd user manager (PipeWire, squeezelite, ...) at boot,
    # without anyone logging in.
    linger = true;
    openssh.authorizedKeys.keys = [
      # bbstation (~/.ssh/id_rsa.pub)
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJx+GtSNau2/eSKqqt+u8lHakdloodRfQz2ur3pHPEkiGCYaW8xKpsRHoEkLob5k+j1ksPrJLJhrVzv2falOkQip53NwYM43QpRmxE9YaCkJz5TGz4A2ytL0/RapwOu/jMWExB1jzdMJbeoI9nFlilPhHAsFNunsLFRCESasbS4IkDK8ADlPU2xBvWQgQABVyBhy9BLklYQg1bmEo3kIn/NrM6TnoZt/HVhXXLAEB/TXp2dTh3wObSTKUvwtoOPubnAmQjr8hfd1l2RRZEljRg9PmKO0h1xxh89fNevN9jeGOWhGA7asl+IQp005XcTaP/j334lnYTvBaLZJn7s1BhWBIi623sCveo5AXy62Xvr8oc45IbKG7tdBHam0foNxTwXgoxB1F4K/1apF9LDDvdV4/ItqoRVgb/6JKRS1Bf6QOVCF7/b7t3eIS5OAnIhs7+xLhHH9uMQoBmWpUv+Tqp8YkFLAGyhQSPZENDFS+c43F97hJI/8sZyE510XA61bqbTul1zmGxpzZEh/1J5FoYJMGqZcYfhUH32XJAx8glylXuULEEINxtqC51YxKbF7rX4AB8lilcr6qiCXjSiD8fDlMRDMdiIzAdOyj8IoV63aIhgL25mWpcgj+fLwP832TsWkOkLMwino15F2nFBdb77sl7xP0sicIrTnjcb7p2Aw== ssh@rafaelcgs.com"
      # personal ed25519 key (the agenix recovery key in secrets/secrets.nix)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWSQ3x9iRPZ3cj11zCwSSWz/vFPakybnrP+324/RuPK rafaelcgs10@gmail.com"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  programs.zsh.enable = true;

  # --- nix ----------------------------------------------------------------------
  # The Pi never builds: bbstation builds and pushes (`--target-host`), which
  # needs rafael to be trusted to import unsigned paths.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "rafael" ];
    auto-optimise-store = true;
    # 32 GB card shared with ~11 GB of music: keep the store lean.
    min-free = 1024 * 1024 * 1024;
    max-free = 3 * 1024 * 1024 * 1024;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # No channels; the flake is the only source.
  nix.channel.enable = false;

  # --- footprint ------------------------------------------------------------------
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;
  programs.command-not-found.enable = false;
  environment.defaultPackages = [ ];
  fonts.fontconfig.enable = false;
  services.udisks2.enable = false;
  xdg.icons.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;

  # Logs in RAM only (spares the SD card), capped small.
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=32M
  '';

  # Compressed swap in RAM; the 2 GB board needs headroom for Home Assistant.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  # Backstop behind zram (zram has the higher priority, so it is used first):
  # lets a short spike, e.g. yt-dlp's deno during a YouTube download, spill to
  # the SD card instead of thrashing the page cache.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2048; # MiB
      priority = 1;
    }
  ];

  # Kill the biggest offender instead of thrashing if RAM runs out.
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    usbutils # lsusb: check the Blue Yeti is seen
    iw
  ];

  system.stateVersion = "26.05";
}
