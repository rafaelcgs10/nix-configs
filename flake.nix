{
  description = "Rafael's NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs2511.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixpkgs-darktable.url = "github:NixOS/nixpkgs/7eea86e9c4edb957d3fa952f7454e6cbdf1721e5";
    nixpkgs-isabelle.url = "github:NixOS/nixpkgs/6a1b486ad3b39263e651cd772b4051cccf218634";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    winapps.url = "github:winapps-org/winapps/main";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative KDE Plasma settings (home-manager module): theme, fonts,
    # shortcuts, panels, input, window rules. Only declared keys are written;
    # monitors, brightness and GUI tweaks stay Plasma's (programs/kde).
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    spektrafilm-art-darktable.url = "github:rafaelcgs10/spektrafilm-art-darktable/36778137aac8005f1dfbc175bbd1fa28007c93fb";

    # NixOS as a WSL2 distribution (the `wsl` host runs inside the WinApps
    # Windows VM). Every input must be fetchable anonymously: no git+ssh
    # inputs, so a fresh machine can evaluate this flake without a GitHub key.
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix: system-wide base16 theming (Catppuccin Mocha) across supported programs
    # (neovim, fzf, tmux, gtk, qt, btop, fuzzel, opencode, ...).
    stylix = {
      url = "github:nix-community/stylix/release-26.05";  # match home-manager
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Packaged Firefox/LibreWolf add-ons (rycee) for declarative installation.
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Affinity (Photo/Designer/Publisher) on Wine. Intentionally NOT following
    # our nixpkgs: the prebuilt closures on cache.forall.systems are built
    # against the flake's own pin, and overriding it would force a local
    # wine build.
    affinity-nix.url = "github:mrshmllow/affinity-nix";

    # Doom Emacs built declaratively (no straight.el, no `doom sync`): the
    # config in home-manager/programs/doom/doom.d and its whole package set are
    # bundled into the resulting Emacs package. Only nixpkgs follows ours so
    # Emacs uses the system libraries. Keep Unstraightened's own emacs-overlay
    # pin: it supplies the package recipes tested against its pinned Doom inputs.
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # age-encrypted secrets. Secrets are committed encrypted under ./secrets and
    # decrypted at activation into /run/agenix using each machine's own SSH host
    # key, so no key material has to be distributed by hand. See secrets/README.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs) lib;

      nixpkgsConfig = {
        allowBroken = true;
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-39.8.10"
          "nix-2.15.3"
        ];
      };

      mkPkgs = system: import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
        # Affinity via overlay (see note in nixos/configuration.nix) — needed
        # here too so the standalone homeConfigurations see pkgs.affinity-v3.
        overlays = [ inputs.affinity-nix.overlays.default ];
      };

      mkHomeArgs = system:
        let
          importWithConfig = input: import input {
            inherit system;
            config = nixpkgsConfig;
          };
        in
        {
          inherit inputs;

          pkgsUnstable = importWithConfig inputs.nixpkgs-unstable;
          pkgsDarktable = importWithConfig inputs.nixpkgs-darktable;
          pkgsIsabelle = importWithConfig inputs.nixpkgs-isabelle;
          spektrafilmPackages = inputs.spektrafilm-art-darktable.packages.${system};
        };

      homeProfiles = {
        default = ./home-manager/profiles/default.nix;
        bbtablet = ./home-manager/profiles/bbtablet.nix;
        wsl = ./home-manager/profiles/wsl.nix;
      };

      mkHomeModules = profile: [
        ./home-manager/home.nix
        homeProfiles.${profile}
        inputs.stylix.homeModules.stylix
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.nix-doom-emacs-unstraightened.homeModule
      ];

      mkHome =
        { system ? "x86_64-linux"
        , profile
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = mkHomeArgs system;
          modules = mkHomeModules profile;
        };

      mkHomeManagerNixosModule = system: homeModules: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = mkHomeArgs system;
        home-manager.users.rafael = {
          imports = homeModules;
        };
      };

      plasmaUnstableModule = { ... }: {
        # KDE Plasma from nixpkgs-unstable (Plasma 6.8 vs 6.6 on the stable
        # release): swap the whole kdePackages set (Plasma, Frameworks, Gear
        # and its Qt 6) for unstable's, which is on the binary cache, and use
        # unstable's plasma6 NixOS module with it. The stable module lists
        # kwin-x11, which 6.8 no longer has (no X11 session), and lacks 6.8's
        # Union style; otherwise the two are the same (checked 2026-11-26).
        # Packages outside kdePackages keep stable Qt.
        disabledModules = [ "services/desktop-managers/plasma6.nix" ];
        imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/desktop-managers/plasma6.nix" ];
        #
        # Stable packages built against kdePackages would otherwise be
        # recompiled locally against unstable's (hours: krita, digikam, obs,
        # telegram, pcsx2...), so those come from unstable as well, prebuilt
        # and on the same Qt as the desktop. Found with
        #   nix build --dry-run .#nixosConfigurations.<host>.config.system.build.toplevel
        # (anything big under "will be built"); add new ones here.
        nixpkgs.overlays = [
          (_final: prev:
            let
              unstable = import inputs.nixpkgs-unstable {
                inherit (prev.stdenv.hostPlatform) system;
                config = nixpkgsConfig;
              };
              withUnstableQt = [
                # would recompile against unstable's kdePackages
                "digikam"
                "eden"
                "kid3"
                "krita"
                "lollypop"
                "ludusavi"
                "melonDS"
                "obs-studio"
                "pcsx2"
                "pinentry-qt"
                "steam"
                "steam-run"
                "telegram-desktop"
                # stable Qt 6 apps: Plasma's Qt plugins (KDE style, colours,
                # file dialog) are built for unstable's newer Qt, which an
                # older Qt refuses to load, so these would look and pick
                # files unlike the rest of the desktop. (simple64 is gone
                # from unstable and stays on stable.)
                "anki"
                "calibre"
                "dolphin-emu"
                "qalculate-qt"
                "rmg"
                "scribus"
                "zoom-us"
              ];
            in
            {
              kdePackages = unstable.kdePackages;
              # Qt 5's KDE Frameworks (whose KIO plugins the plasma6 module
              # links for Qt 5 apps) take kdePackages (extra-cmake-modules,
              # plasma-wayland-protocols) from the top level; hand the Qt 5 set
              # stable's so its packages stay the cached stable builds.
              libsForQt5 = prev.libsForQt5.overrideScope (_: super: {
                inherit (prev) kdePackages;
                __internalKF5 = super.__internalKF5.override { inherit (prev) kdePackages; };
              });
            }
            // prev.lib.genAttrs withUnstableQt (name: unstable.${name}))
        ];
      };

      mkHost =
        { system ? "x86_64-linux"
        , common ? true
        , homeProfile ? null
          # Explicit home-manager module list, bypassing home.nix and the
          # profile mechanism (for hosts that need a much slimmer home).
        , homeModules ? if homeProfile == null then null else mkHomeModules homeProfile
        , modules
        }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules =
            lib.optionals common [ ./nixos/configuration.nix ]
            # configuration.nix carries the shared nixpkgs config; hosts that
            # skip it still need allowUnfree etc. for the home-manager profile.
            ++ lib.optionals (!common) [ { nixpkgs.config = nixpkgsConfig; } ]
            ++ modules
            ++ lib.optionals (homeModules != null) [
              home-manager.nixosModules.home-manager
              (mkHomeManagerNixosModule system homeModules)
            ];
        };

      hosts = {
        bbstation = mkHost {
          homeProfile = "default";
          modules = [
            plasmaUnstableModule
            ./nixos/bbstation/boot-loader.nix
            ./nixos/bbstation/hardware-configuration.nix
            ./nixos/plasma.nix
            ./nixos/io-performance.nix
            ./nixos/font-rendering.nix
            ./nixos/plymouth.nix
          ];
        };

        bbtablet = mkHost {
          homeProfile = "bbtablet";
          modules = [
            ./nixos/bbtablet/boot-loader.nix
            ./nixos/bbtablet/hardware-configuration.nix
            ./nixos/nas-rclone.nix
            ./nixos/plymouth.nix
          ];
        };

        thinkpad-e14 = mkHost {
          homeProfile = "default";
          modules = [
            plasmaUnstableModule
            ./nixos/thinkpad-e14/boot-loader.nix
            ./nixos/thinkpad-e14/hardware-configuration.nix
            ./nixos/plasma.nix
            ./nixos/nas-rclone.nix
            ./nixos/thinkpad-e14/rapidraw.nix
            ./nixos/io-performance.nix
            ./nixos/font-rendering.nix
            ./nixos/plymouth.nix
            # Only hosts whose key is a recipient in secrets/secrets.nix may
            # import this; bbstation/bbtablet follow once they are reachable.
            ./nixos/agenix.nix
          ];
        };

        # NixOS-WSL inside the WinApps Windows VM. No shared configuration.nix
        # (NetworkManager, PipeWire, printing, firewall... are meaningless in
        # WSL); the slim `wsl` home profile carries Doom, zsh and nvim.
        wsl = mkHost {
          common = false;
          homeProfile = "wsl";
          modules = [
            inputs.nixos-wsl.nixosModules.default
            ./nixos/wsl/configuration.nix
          ];
        };

        # Raspberry Pi 4 (2 GB) headless music box. Built on bbstation (binfmt
        # emulation), never on the Pi. See nixos/vovo/README.md.
        #   SD image: nix build .#nixosConfigurations.vovo.config.system.build.sdImage
        vovo = mkHost {
          system = "aarch64-linux";
          common = false;
          homeModules = [ ./home-manager/profiles/vovo.nix ];
          modules = [ ./nixos/vovo ];
        };
      };
    in
    {
      nixosConfigurations = hosts // {
        thinkpad = hosts.thinkpad-e14;
      };

      homeConfigurations = {
        "rafael@bbstation" = mkHome {
          profile = "default";
        };

        "rafael@bbtablet" = mkHome {
          profile = "bbtablet";
        };

        "rafael@thinkpad-e14" = mkHome {
          profile = "default";
        };

        "rafael@thinkpad" = mkHome {
          profile = "default";
        };

        "rafael@wsl" = mkHome {
          profile = "wsl";
        };

      };

      # Per-project dev shells. Enter with `nix develop .#darktable` or, from a
      # checkout, `echo 'use flake ~/nix-configs#darktable' > .envrc && direnv allow`.
      devShells.x86_64-linux.darktable =
        import ./nix-shells/c++/darktable/shell.nix {
          pkgs = mkPkgs "x86_64-linux";
        };

      # Refresh vovo's vendored Wikidata artist/works snapshot (name correction
      # for voice commands, nixos/vovo/names.nix). Run from the repo root:
      #   nix run .#vovo-names-update && git diff --stat nixos/vovo/names
      apps.x86_64-linux.vovo-names-update = {
        type = "app";
        program = toString ((mkPkgs "x86_64-linux").writers.writePython3Bin "vovo-names-update"
          { flakeIgnore = [ "E501" ]; }
          (builtins.readFile ./nixos/vovo/names/wikidata-update.py)) + "/bin/vovo-names-update";
      };
    };
}
