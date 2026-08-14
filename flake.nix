{
  description = "Rafael's NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs2511.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixpkgs-darktable.url = "github:NixOS/nixpkgs/7eea86e9c4edb957d3fa952f7454e6cbdf1721e5";
    nixpkgs-isabelle.url = "github:NixOS/nixpkgs/6a1b486ad3b39263e651cd772b4051cccf218634";
    nixpkgs-lmstudio.url = "github:NixOS/nixpkgs/ffb547307d66d88c2af80c34818ac064d7958231";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    winapps.url = "github:winapps-org/winapps/main";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager/552888403867ba9cfd170c1e7edddabe54ef4342";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    spektrafilm-art-darktable.url = "github:rafaelcgs10/spektrafilm-art-darktable/d1ff13f11096f3ac8d6043853fbb89146cbed982";

    # CLI for COSMIC toplevel management (scratchpad chat toggles).
    # Unofficial but source-reviewed at this pin: no network/exec/fs access.
    cos-cli.url = "github:estin/cos-cli/fe8c52016888302d6239ef53f1dbf876d8552dc2";

    # Stylix: system-wide base16 theming (Rosé Pine) across supported programs
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

    # Declarative COSMIC desktop configuration (used to apply the Rosé Pine
    # COSMIC theme, since Stylix has no COSMIC target).
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
          pkgsLmstudio = importWithConfig inputs.nixpkgs-lmstudio;
          plasmaManager = inputs.plasma-manager;
          spektrafilmPackages = inputs.spektrafilm-art-darktable.packages.${system};
        };

      homeProfiles = {
        default = ./home-manager/profiles/default.nix;
        bbtablet = ./home-manager/profiles/bbtablet.nix;
      };

      mkHomeModules = profile: [
        ./home-manager/home.nix
        homeProfiles.${profile}
        inputs.stylix.homeModules.stylix
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
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

      mkHomeManagerNixosModule = system: profile: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = mkHomeArgs system;
        home-manager.users.rafael = {
          imports = mkHomeModules profile;
        };
      };

      cosmicUnstableModule = { ... }: {
        # Keep the stable NixOS module API, but replace its hard-coded COSMIC
        # packages as one suite. Importing the unstable module would reference
        # NixOS options that do not exist on the stable release.
        nixpkgs.overlays = [
          (_final: prev:
            let
              unstable = import inputs.nixpkgs-unstable {
                inherit (prev.stdenv.hostPlatform) system;
                config = nixpkgsConfig;
              };
              cosmicPackages = [
                "cosmic-applets"
                "cosmic-bg"
                "cosmic-comp"
                "cosmic-edit"
                "cosmic-files"
                "cosmic-greeter"
                "cosmic-icons"
                "cosmic-idle"
                "cosmic-initial-setup"
                "cosmic-launcher"
                "cosmic-notifications"
                "cosmic-osd"
                "cosmic-panel"
                "cosmic-player"
                "cosmic-randr"
                "cosmic-reader"
                "cosmic-screenshot"
                "cosmic-session"
                "cosmic-settings"
                "cosmic-settings-daemon"
                "cosmic-store"
                "cosmic-term"
                "cosmic-wallpapers"
                "cosmic-workspaces-epoch"
                "xdg-desktop-portal-cosmic"
              ];
            in
            prev.lib.genAttrs cosmicPackages (name: unstable.${name}) // {
              # The stable module still uses the old attribute name.
              cosmic-applibrary = unstable.cosmic-app-library;
            })
        ];
      };

      mkHost =
        { system ? "x86_64-linux"
        , common ? true
        , homeProfile ? null
        , modules
        }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules =
            lib.optionals common [ ./nixos/configuration.nix ]
            ++ modules
            ++ lib.optionals (homeProfile != null) [
              home-manager.nixosModules.home-manager
              (mkHomeManagerNixosModule system homeProfile)
            ];
        };

      hosts = {
        bbstation = mkHost {
          homeProfile = "default";
          modules = [
            cosmicUnstableModule
            ./nixos/bbstation/boot-loader.nix
            ./nixos/bbstation/hardware-configuration.nix
            ./nixos/io-performance.nix
            ./nixos/font-rendering.nix
          ];
        };

        bbtablet = mkHost {
          homeProfile = "bbtablet";
          modules = [
            ./nixos/bbtablet/boot-loader.nix
            ./nixos/bbtablet/hardware-configuration.nix
          ];
        };

        thinkpad-e14 = mkHost {
          homeProfile = "default";
          modules = [
            cosmicUnstableModule
            ./nixos/thinkpad-e14/boot-loader.nix
            ./nixos/thinkpad-e14/hardware-configuration.nix
            ./nixos/io-performance.nix
            ./nixos/font-rendering.nix
          ];
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

      };

      # Per-project dev shells. Enter with `nix develop .#darktable` or, from a
      # checkout, `echo 'use flake ~/nix-configs#darktable' > .envrc && direnv allow`.
      devShells.x86_64-linux.darktable =
        import ./nix-shells/c++/darktable/shell.nix {
          pkgs = mkPkgs "x86_64-linux";
        };
    };
}
