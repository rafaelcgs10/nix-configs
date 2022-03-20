{ config, pkgs, lib, ... }:

{
  imports = [
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/5a6756294553fc3aa41e11563882db78c2dfbb4c.tar.gz" }/raspberry-pi/4"
    ../modules/qbittorrent.nix
    ./fan-control/default.nix
  ];

  boot.kernelParams = [
    "usb-storage.quirks=152d:0578:u"
    "usbcore.quirks=152d:0578:u"
    "console=ttySO,115200n8"
    "console=tty1MA0n115200n8"
    "console=tty0"
    "mitigations=off"
  ];

  boot.kernelModules = [ "bfq" ];

  boot.extraModprobeConfig = ''
      options iwlwifi power_save=0
  '';

  # Printer and scanner stuff
  # Enable automatic discovery of the printer from other Linux systems with avahi running.
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*:631" ];
  services.printing.allowFrom = [ "all" ];
  services.printing.defaultShared = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
  users.users.rafael.extraGroups = [ "scanner" "lp" ];

  boot.postBootCommands = ''
   echo mq-deadline > /sys/block/sda/queue/scheduler
   echo mq-deadline > /sys/block/sdb/queue/scheduler
   echo 1 > /sys/block/sda/queue/iosched/fifo_batch
  '';

  networking.wireless.enable = false;

  services.journald.extraConfig = ''
    Storage = volatile
    Compress = yes
    RuntimeMaxUse = 256M
    RuntimeMaxFileSize = 16M
  '';

  my.raspberry-pi = {
    fan-control.enable = true;
  };

  boot.loader.raspberryPi.firmwareConfig = ''
    arm_freq=1750
    over_voltage=1
    dtparam=sd_poll_once=on
  '';

  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  boot.kernel.sysctl = {
    "sched_latency_ns" = "1000000";
    "sched_min_granularity_ns" = "100000";
    "sched_migration_cost_ns"  = "7000000";
  };

  fileSystems."/bighd" =
    { device = "/dev/disk/by-label/bighd";
    fsType = "btrfs";
    options = [ "rw" "nofail" "noatime" "compress=zstd" "space_cache" ];
  };

  fileSystems."/hugehd" =
    { device = "/dev/disk/by-label/hugehd";
    fsType = "btrfs";
    options = [ "rw" "nofail" "noatime" "compress=zstd" "space_cache" ];
  };


  networking.hostName = "raspberry-pi-4";

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=1777" "lazytime" "nosuid" "nodev" ];
  };


  services.earlyoom = {
    enable = true;
    useKernelOOMKiller = true;
    freeMemThreshold = 5;
  };

  hardware = {
    # Enable GPU acceleration
    raspberry-pi."4".fkms-3d = {
      enable = true;
      cma = 512;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xmonad";

  services.samba-wsdd.enable = true;
  services.samba-wsdd.discovery = true;
  services.samba-wsdd.interface = "eth0";

  services.samba = {
    package = pkgs.sambaFull;
    enable = true;
    securityType = "user";
    nsswins = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      load printers = yes
      # printing = cups
      # printcap name = cups
      # smb ports = 139
    #use sendfile = yes
    #max protocol = smb2
      hosts allow = 10.100.0.2/32 10.100.0.3/32 192.168.15.1/24 192.168.15.118
      map to guest = bad user
    '';
    shares = {
      # printers = {
      #   comment = "All Printers";
      #   path = "/var/spool/samba";
      #   public = "yes";
      #   browseable = "yes";
      #   "printer name" = "queue";
      #   # to allow user 'guest account' to print.
      #   "guest ok" = "yes";
      #   writable = "no";
      #   printable = "yes";
      #   "create mode" = 0700;
      # };
      private = {
        path = "/hugehd/downloader";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "downloader";
        "force group" = "users";
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/spool/samba 1777 root root -"
  ];

  services.xserver = {
    resolutions = [ { x = 1280; y = 720; } { x = 1024; y = 768; }];
  };

  services.xserver.autorun = false;

  users.users.downloader = {
    isNormalUser = true;
    home = "/hugehd/downloader";
    extraGroups = [ "wheel" "networkmanager" "users" ];
  };

  # services = {
  #   udev.extraRules = ''
  #     ACTION=="add|change", KERNEL=="sd[ab][!0-9]", ATTR{queue/scheduler}="kyber"
  #   '';
  #   irqbalance.enable = true;
  # };

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "downloader";
    group = "users";
  };

  services.vsftpd = {
    enable = true;
    localUsers = true;
    writeEnable = true;
    anonymousUser = true;
    extraConfig = ''
      pasv_enable=YES
      pasv_min_port=64000
      pasv_max_port=64000
      port_enable=YES
    '';
  };

  services.qbittorrent.enable = true;
  users.users.qbittorrent.isSystemUser = true;

  # Enable cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * *     rafael    cd /home/rafael/zsh_history; for c in zsh_history.sync-conflict-*; do git merge-file zsh_history empty.history $c;done; rm zsh_history.sync-conflict-*"
      "1 0 */1 * *      root          reboot"
    ];
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };

    daemonIONiceLevel = 10;
    daemonNiceLevel = 5;
    buildCores = 2;
  };

  services.syncthing = {
    user = "rafael";
    group = "users";
    dataDir = "/hugehd/Syncthing";
    enable = true;
    relay.enable = true;
    guiAddress = "0.0.0.0:8384";
  };

  systemd.services.jellyfin.serviceConfig = {
    MemoryMax = "1G";
  };

  systemd.services.syncthing.serviceConfig = {
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 6;
    MemoryMax = "1G";
    CPUQuota = "50%";
    BlockIOWeight = 100;
  };

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/home/rafael/wireguard-keys/private";

      peers = [
        # List of allowed peers.
        { # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
          publicKey = "v/y85aSvfkgg4nt3E1SkQ3i0M0/iXLuG1qajFzEfBzk=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.100.0.2/32" ];
        },
        { # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
          publicKey = "7XLVgdbk4n8TAID5wEP4mrrvyYZ42lTiCQZO3PjjH14=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    verbose = true;
    username = "rafaelcgs10@gmail.com";
    password = builtins.readFile /home/rafael/cf-api-token;
    zone = "rafaelcgs.com";
    domains = [ "vpn.rafaelcgs.com" ];
  };

  # Docker config
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  systemd.services.docker.serviceConfig.KillMode = "mixed";

  virtualisation.oci-containers.containers.pi-hole = {
    autoStart = true;
    image = "pihole/pihole:latest";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "80:80/tcp"
    ];
    volumes = [
      "/etc/pihole/:/etc/pihole/"
      "/etc/dnsmasq.d/:/etc/dnsmasq.d/"
    ];
    environment = {
      TZ = "America/Sao_Paulo";
      WEBTHEME = "default-darker";
      WEBPASSWORD = "pihole";
    };
    extraOptions = [ "--network=host" ];
  };
}
