# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  homemanager = import <home-manager> {};
in {
  imports =
    [ # Include the results of the hardware scan.
      ./cachix.nix
      ./boot-loader.nix
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];
  nixpkgs.config.permittedInsecurePackages = [
    # "python-2.7.18.6"
    # "python-2.7.18.7"
    "nix-2.15.3"
  ];
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = "nix-command flakes";

  services.udisks2 = {
    enable = true;
  };

  # networking.wireless.enable = true;
  #  Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
   enable = true;
   # dns = "none";
   wifi.powersave = false;
   # extraConfig = ''
   #    [main]
   #    rc-manager=file
   # '';
  };
  networking = {
    nameservers = [  "2a07:a8c0::#7de4a9.dns.nextdns.io" "45.90.28.0#7de4a9.dns.nextdns.io" "45.90.30.0#7de4a9.dns.nextdns.io" "2a07:a8c1::#7de4a9.dns.nextdns.io" "45.90.28.219" "1.1.1.1" ];
  };
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    dnsovertls = "true";
  };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Select internationalisation properties.
  # i18n.defaultLocale = "pt_BR.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };


  services = {
    # gnome.gnome-keyring.enable = true;
    upower.enable = true;

    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };
  };

  services.xserver.windowManager.xmonad.enable = true;


  # Xserver basic
  programs.dconf.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  services.xserver = {
    enable = true;

    desktopManager = {
      # plasma5.enable = true;
      plasma6.enable = true;
      xterm.enable = false;
    };

  };

  services = {
    displayManager = {
      # defaultSession = "plasmawayland";
      defaultSession = "plasma";
        sddm.enable = true;
        # defaultSession = "xfce";
    };
  };

  services.gvfs = {
    enable = true;
    # package = lib.mkForce pkgs.gnome3.gvfs;
  };

  # Configure keymap in X11
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rafael = {
    isNormalUser = true;
    password = "rafael";
    home = "/home/rafael";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "users" ];
  };
  nix.settings.trusted-users = [ "root" "rafael" ];

  users.extraUsers.rafael = {
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # Automount ecrypts
  security.pam.enableEcryptfs = true;
  # Apparmor
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
    packages = with pkgs; [
      apparmor-profiles
      apparmor-utils
      apparmor-parser
      libapparmor
    ];
  };
  # programs.firejail = {
  #   enable = true;
  #   wrappedBinaries = {
  #     firefox = {
  #       executable = "${pkgs.firefox}/bin/firefox";
  #       profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
  #       # desktop = "''${pkgs.firefox}/share/applications/firefox.desktop";
  #       # extraArgs = [ "--private" ];
  #     };
  #     brave = "${lib.getBin pkgs.brave}/bin/brave";
  #     # brave = {
  #     #   executable = "${pkgs.lib.getBin pkgs.brave}/bin/brave";
  #     #   profile = "${pkgs.firejail}/etc/firejail/brave.profile";
  #     # };
  #   };
  # };

  # nixpkgs.overlays = [
  #   (self: super: {
  #     firejail = super.firejail.overrideAttrs (old: {
  #       version = "0.9.70";
  #       src = super.fetchFromGitHub {
  #         owner = "netblue30";
  #         repo = "firejail";
  #         rev = "0.9.70";
  #         sha256  = "sha256-x1txt0uER66bZN6BD6c/31Zu6fPPwC9kl/3bxEE6Ce8=";
  #       };
  #     });
  #   })
  # ];

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    htop
    parted
    ntfs3g
    nfs-utils
    busybox
    terminator
    zsh
    vim
    homemanager.home-manager
    btrfs-progs
    compsize
    smartmontools
    wireguard-tools
    cloudflared
    openh264
    ecryptfs
    # ecryptfs-helper
    utillinux
    hicolor-icon-theme
    ripgrep
    coreutils
    fd
    docker-compose
    cachix
    gnutar gzip gnumake
    lxqt.lxqt-policykit
    libv4l
    v4l-utils
    rclone

    # libnotify
    # libdbusmenu
  ];

  services.teamviewer.enable = true;

  # printing
  services.printing.enable = true;
  services.avahi.enable = true;
  # services.avahi.nssmdns = true;
  # services.avahi.extraServiceFiles = {
  #   ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
  #   smb = ''
  #   <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
  #   <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
  #   <service-group>
  #     <name replace-wildcards="yes">%h</name>
  #     <service>
  #       <type>_smb._tcp</type>
  #       <port>445</port>
  #     </service>
  #   </service-group>
  # '';
  # };

  # to wireguard work with networkmanager
  networking.firewall = {
    # if packets are still dropped, they will show up in dmesg
    # logReversePathDrops = true;
    # wireguard trips rpfilter up
   #  extraCommands = ''
   #   ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
   #   ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
   # '';
    extraStopCommands = ''
     ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
     ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
   '';
  };

  services.smartd = {
    enable = true;
    notifications.x11.enable = true;
    # notifications.mail.enable = true;
    notifications.wall.enable = true;
  };

  # services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # pinentryFlavor = "curses";
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.sshguard.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  networking.firewall.allowedTCPPorts = [ 8080 8384 8096 53 137 136 139 445 3080 80 5357 631 8443 8265 8181 8266 8267 22000 63786 43686 47849 33976 53277 51372];
  networking.firewall.allowedUDPPorts = [ 9091 53 49152 3080 3702 631 8443 8265 8266 8267 8181 22000 63786 43686 47849 33976 53277 51372];
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; }  ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  nix.settings.download-buffer-size = 524288000;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
