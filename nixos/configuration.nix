# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

let
  homeManagerPackage = inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager;
in {
  imports =
    [
      ./cachix.nix
    ];
  nixpkgs.config.permittedInsecurePackages = [
    # "python-2.7.18.6"
    # "python-2.7.18.7"
    "electron-39.8.10"
    "nix-2.15.3"
  ];
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = "nix-command flakes";

  # Binary cache for affinity-nix (Affinity on Wine) — avoids building a
  # patched wine locally.
  nix.settings.extra-substituters = [ "https://cache.forall.systems" ];
  nix.settings.extra-trusted-public-keys = [
    "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
  ];

  # Rebuild half of the auto-upgrade split: the flake.lock update, commit and
  # push happen an hour earlier as rafael (nix-configs-update user timer in
  # home-manager/programs/nix-configs-autoupdate.nix); this root service only
  # rebuilds the committed state. --no-write-lock-file guarantees root never
  # writes into the checkout, which would leave root-owned files behind and
  # break rafael's own git with permission errors.
  system.autoUpgrade = {
    enable = true;
    flake = "/home/rafael/nix-configs/";
    flags = [
      "--print-build-logs"
      "--no-write-lock-file"
    ];
    dates = "12:00";
    randomizedDelaySec = "45min";
  };

  # Desktop notifications (COSMIC) around the upgrade: one when it starts and
  # one on finish with the package version bumps between the old and new
  # generation (nvd diff, capped at 10 lines in the popup; the full diff lands
  # in this service's journal). The service runs as root, so notify-send is
  # bridged into rafael's session bus with runuser. Every hook is best-effort
  # ("-" prefix, || true): an upgrade must never fail just because nobody was
  # logged in to see the popup.
  #
  # The failure branch also drives the revert strategy: if the run failed
  # WITHOUT switching generations, the new lock is unbuildable and rafael's
  # nix-configs-revert user service rolls the auto-update commit back (see
  # home-manager/programs/nix-configs-autoupdate.nix). If it failed after
  # switching (like a network mount racing the activation), the lock is fine
  # and reverting would be a false positive — notify only.
  systemd.services.nixos-upgrade.serviceConfig =
    let
      notify = pkgs.writeShellScript "nixos-upgrade-notify" ''
        uid=$(${pkgs.coreutils}/bin/id -u rafael)
        exec ${pkgs.util-linux}/bin/runuser -u rafael -- \
          ${pkgs.coreutils}/bin/env "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus" \
          ${pkgs.libnotify}/bin/notify-send -a "NixOS upgrade" "$@"
      '';
    in
    {
      ExecStartPre = [
        ("-" + pkgs.writeShellScript "nixos-upgrade-notify-start" ''
          # Remember the generation we started from for the finish diff.
          ${pkgs.coreutils}/bin/readlink -f /run/current-system \
            > /run/nixos-upgrade.prev-system || true
          ${notify} "NixOS upgrade started" "Rebuilding from /home/rafael/nix-configs"
        '')
      ];
      ExecStopPost = [
        ("-" + pkgs.writeShellScript "nixos-upgrade-notify-done" ''
          if [ "$SERVICE_RESULT" != success ]; then
            prev=$(${pkgs.coreutils}/bin/cat /run/nixos-upgrade.prev-system 2>/dev/null || true)
            cur=$(${pkgs.coreutils}/bin/readlink -f /run/current-system)
            if [ -n "$prev" ] && [ "$prev" != "$cur" ]; then
              # The generation switched, so the new lock built and activated —
              # the failure is a degraded unit (e.g. a network mount racing the
              # switch), not the lock's fault. Never revert for this.
              ${notify} -u critical "NixOS upgrade: switched with failing units" \
                "New generation is active but some units failed — see: systemctl --failed"
            else
              # Nothing switched: the new lock does not build/activate. Have
              # rafael's session revert the auto-update commit (root must not
              # write into the checkout).
              ${notify} -u critical "NixOS upgrade failed" \
                "$SERVICE_RESULT — reverting today's flake.lock update; see: journalctl -u nixos-upgrade"
              uid=$(${pkgs.coreutils}/bin/id -u rafael)
              ${pkgs.util-linux}/bin/runuser -u rafael -- \
                ${pkgs.coreutils}/bin/env "XDG_RUNTIME_DIR=/run/user/$uid" \
                "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus" \
                ${pkgs.systemd}/bin/systemctl --user start nix-configs-revert.service
            fi
            exit 0
          fi

          prev=$(${pkgs.coreutils}/bin/cat /run/nixos-upgrade.prev-system 2>/dev/null || true)
          cur=$(${pkgs.coreutils}/bin/readlink -f /run/current-system)
          if [ -z "$prev" ] || [ "$prev" = "$cur" ]; then
            ${notify} "NixOS upgrade finished" "Already up to date — no changes."
            exit 0
          fi

          # nvd lines look like "[U.]  #12  firefox  128.0 -> 129.0"; strip the
          # status/index columns for the popup.
          diff=$(${pkgs.nvd}/bin/nvd diff "$prev" "$cur" || true)
          printf '%s\n' "$diff"
          changes=$(printf '%s\n' "$diff" \
            | ${pkgs.gnugrep}/bin/grep '^\[' \
            | ${pkgs.gnused}/bin/sed -E 's/^\[[^]]*\][[:space:]]+#[0-9]+[[:space:]]+//' \
            || true)
          total=$(printf '%s\n' "$changes" | ${pkgs.gnugrep}/bin/grep -c . || true)
          total=''${total:-0}
          body=$(printf '%s\n' "$changes" | ${pkgs.coreutils}/bin/head -n 10)
          if [ "$total" -gt 10 ]; then
            body="$body
    … and $((total - 10)) more (journalctl -u nixos-upgrade)"
          fi
          ${notify} "NixOS upgrade finished" "''${body:-New generation activated.}"
        '')
      ];
    };

  # nixos-upgrade.service runs as root, but the flake above is rafael's
  # checkout, so git's ownership check (CVE-2022-24765) rejects even reading
  # it: "repository is not owned by current user". Instead of the wiki's
  # imperative `git config --global --add safe.directory` (a file in root's
  # home), declare it in the system-wide /etc/gitconfig, which every user's
  # git — root's included — reads. rafael's own git is unaffected: the
  # per-user home-manager config overrides this file.
  programs.git = {
    enable = true;
    config.safe.directory = "/home/rafael/nix-configs"; # exact match, no trailing slash
  };


  # Auto-GC: keeps the store from growing unbounded
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 5d";
  };
  # Safety valve: GC mid-build if free space drops below 5 GiB
  nix.settings.min-free = 5 * 1024 * 1024 * 1024;
  nix.settings.max-free = 20 * 1024 * 1024 * 1024;

  # Cap journald so logs don't grow unbounded (was at 1.9G on bbstation)
  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

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
    nameservers = [  "2a07:a8c0::#6e9815.dns.nextdns.io" "45.90.28.0#6e9815.dns.nextdns.io" "45.90.30.0#6e9815.dns.nextdns.io" "2a07:a8c1::#6e9815.dns.nextdns.io" ];
    # nameservers = [  "localhost" ];
  };
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      Domains = [ "~." ];
      FallbackDNS = [ "1.1.1.1#one.one.one.one" ];
      DNSOverTLS = "true";
    };
  };
  # services.pihole-ftl = {
  #   enable = true;
  #   openFirewallDNS = true;              # To open port 53 for DNS traffic
  #   openFirewallDHCP = true;
  #   openFirewallWebserver = true;

  #   # Settings documented at <https://docs.pi-hole.net/ftldns/configfile/>
  #   settings = {
  #     dns.upstreams = [ "1.1.1.1" "8.8.8.8" ];   # To use Cloudflare's DNS Servers
  #   };

  #   # Lists can be added via URL
  #   lists = [
  #     {
  #       url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
  #       type = "block";
  #       enabled = true;
  #       description = "Sample blocklist by hagezi";
  #     }
  #   ];
  # };
  # services.pihole-web = {
  #   enable = true;
  #   ports = [
  #     "9090"
  #   ];
  # };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Time sync must not depend on DNS. `services.resolved` below runs strict
  # DNS-over-TLS, so a wrong clock makes every resolver certificate look
  # "not yet valid" and kills DNS outright -- and then timesyncd cannot
  # resolve *.nixos.pool.ntp.org to repair the clock. A host whose RTC
  # resets (dead coin cell) stays wedged forever. Appending time.cloudflare.com
  # by literal IP breaks that deadlock: NTP is unauthenticated anyway, so
  # there is nothing to validate against the bad clock.
  services.timesyncd.servers = config.networking.timeServers ++ [
    "162.159.200.1"
    "162.159.200.123"
  ];

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
  # services.postgresql = {
  #   enable = true;
  #   port = 5432;
  #   enableTCPIP = true;
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     #...
  #     #type database DBuser origin-address auth-method
  #     local all       all     trust
  #     # ipv4
  #     host  all      all     127.0.0.1/32   trust
  #     # ipv6
  #     host all       all     ::1/128        trust
  #   '';
  # };



  services = {
    # gnome.gnome-keyring.enable = true;
    upower.enable = true;

    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };
  };


  # Fonts. Install the Hack Nerd Font system-wide and make it the default
  # monospace so terminals (COSMIC Terminal, alacritty, ...) render the
  # Starship powerline separators/icons from the same font as the text
  # instead of a mismatched fallback (which breaks the powerline bar).
  fonts = {
    packages = [ pkgs.nerd-fonts.hack ];
    fontconfig.defaultFonts.monospace = [ "Hack Nerd Font Mono" ];
  };

  # Xserver basic
  programs.dconf.enable = true;
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # Display manager / desktop environment is configured per-host
  # (see each host's hardware-configuration.nix).
  services.gnome.gnome-remote-desktop.enable = true;

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
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "users" "scanner" ];
  };
  nix.settings.trusted-users = [ "root" "rafael" ];

  users.extraUsers.rafael = {
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

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

  # Affinity (Wine) packages. The overlay is the supported install path: the
  # flake's own `packages` output refuses to eval (unfree) since it uses the
  # flake's nixpkgs, while the overlay evaluates against ours (allowUnfree).
  # Wine itself still comes from affinity-nix's pinned nixpkgs, so the big
  # wine closure stays substitutable from cache.forall.systems.
  nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

  # A permanent home, OFF the encrypted home directory, for Affinity's
  # writable overlay layer. Affinity needs an overlayfs mount to save its
  # state, but overlayfs can't keep that writable layer on our ecryptfs home
  # (the mount fails and Affinity won't start). So we park it here on the
  # plain btrfs disk and symlink ~/.local/{share,state}/affinity-v3 to it
  # from home-manager (full explanation in
  # home-manager/programs/graphical-apps/extras.nix). Owned by the user so
  # the launcher can write it; the trailing "-" age means never auto-cleaned.
  systemd.tmpfiles.rules = [
    "d /var/lib/affinity-nix       0700 rafael users - -"
    "d /var/lib/affinity-nix/data  0700 rafael users - -"
    "d /var/lib/affinity-nix/state 0700 rafael users - -"
  ];

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
    homeManagerPackage
    btrfs-progs
    compsize
    smartmontools
    wireguard-tools
    cloudflared
    openh264
    util-linux
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
    nix-index
    gphoto2
    gphoto2fs
    libgphoto2
    kdePackages.kamera
    waypipe

    # (pkgs.writeShellScriptBin "python" ''
    #   export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
    #   exec ${pkgs.python311}/bin/python "$@"
    # '')
    # libnotify
    # libdbusmenu
  ];


  # printing
  services.printing = {
    enable = true;
    extraConf = ''
      Listen /run/cups/cups.sock
    '';
  };
  services.avahi.enable = true;
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.udev.packages = [ pkgs.sane-airscan ];
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
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
      AllowUsers = [ "rafael" ];
    };
  };



  # services.sshguard.enable = true;
  # services.fail2ban.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  networking.firewall.allowedTCPPorts = [ 5432 8080 8384 8096 53 137 136 139 445 3080 80 5357 631 8443 8265 8181 8266 8267 22000 63786 43686 47849 33976 53277 51372 3389 ];
  networking.firewall.allowedUDPPorts = [ 5432 9091 53 49152 3080 3702 631 8443 8265 8266 8267 8181 22000 63786 43686 47849 33976 53277 51372 3389 ];
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; }  ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };
  services.flatpak.enable = true;
  # systemd.services.flatpak-repo = {
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.flatpak ];
  #   script = ''
  #     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #   '';
  # };


  nix.settings.download-buffer-size = 524288000;

 # programs.nix-ld = {
 #    enable = true;
 #    libraries = with pkgs; [
 #      zlib zstd stdenv.cc.cc curl openssl attr libssh bzip2 libxml2 acl libsodium util-linux xz systemd
 #      mesa
 #      fontconfig   
 #      libgbm
 #      libGLU
 #      libGL
 #      libglibutil
 #    ];
 #  };
  # programs.nix-ld.libraries = with pkgs; [
  #   libdrm
  #   mesa
  #   libxkbcommon
  #   glibc
  #   gtk3
  #   libGL
  #   glib
  #   glibc
  #   libnss-mysql
  #   nss
  #   nspr
  #   at-spi2-atk
  #   remarkable-toolchain
  #   cups
  #   dbus
  #   pango
  #   cairo
  #   nx-libs
  #   xorg.libX11
  #   xorg.libXcomposite
  #   xorg.libXdamage
  #   xorg.libXext
  #   xorg.libXfixes
  #   xorg.libXrandr
  #   expat
  #   xorg.libxcb
  #   alsa-lib

  # ];

  # set default timeout to 10s - many times reboot waits 90s
  systemd.settings = {
    Manager = {
      DefaultTimeoutStopSec = "10s";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
