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

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  nix.autoOptimiseStore = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
   enable = true;
   wifi.powersave = false;
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };


  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;

    dbus = {
      enable = true;
      packages = [ pkgs.gnome.dconf ];
    };
  };

  # Xserver basic
  services.xserver = {
    enable = true;

    desktopManager = {
      xfce.enable = true;
      xterm.enable = false;
    };

    displayManager = {
        lightdm.enable = true;
        defaultSession = "xfce";
    };
  };

  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome3.gvfs;
  };

  # Configure keymap in X11
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rafael = {
    isNormalUser = true;
    password = "rafael";
    home = "/home/rafael";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "users" ];
  };
  nix.trustedUsers = [ "root" "rafael" ];

  users.extraUsers.rafael = {
    shell = pkgs.zsh;
  };

  # Automount ecrypts
  security.pam.enableEcryptfs = true;

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    htop
    parted
    ntfs3g
    terminator
    zsh
    vim
    homemanager.home-manager
    btrfs-progs
    compsize
    smartmontools

    ecryptfs
    ecryptfs-helper
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

    # libnotify
    # libdbusmenu
  ];

  service.smartd = {
    enable = true;
    notifications.x11.enable = true;
    # notifications.mail.enable = true;
    notifications.wall.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  environment.etc."isabelle-docker/bin/isabelle" = {
    mode = "0555";
    text =  ''
      #!${pkgs.bash}/bin/bash
      docker run --rm -i rafaelcgs10/isabelle-emacs:1.1 /app/bin/isabelle $1
    '';
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
  networking.firewall.allowedTCPPorts = [ 8080 8384 53 137 136 139 445 3080 80 ];
  networking.firewall.allowedUDPPorts = [ 9091 53 49152 3080 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
