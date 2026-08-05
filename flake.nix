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

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/9714d18e3b55f61531a42795779a941365cb2588";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spektrafilm-art-darktable.url = "github:rafaelcgs10/spektrafilm-art-darktable/bc85cd944c32b8a1a96452aafdd3a5eb082fa50c";

    # CLI for COSMIC toplevel management (scratchpad chat toggles).
    # Unofficial but source-reviewed at this pin: no network/exec/fs access.
    cos-cli.url = "github:estin/cos-cli/fe8c52016888302d6239ef53f1dbf876d8552dc2";

    # Catppuccin theming for supported programs (neovim, fzf, ...).
    catppuccin.url = "github:catppuccin/nix";

    # Packaged Firefox/LibreWolf add-ons (rycee) for declarative installation.
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative COSMIC desktop configuration (used to apply the Catppuccin
    # COSMIC theme, since catppuccin/nix has no COSMIC module).
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
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
          pkgsEmacs = import nixpkgs {
            inherit system;
            config = nixpkgsConfig;
            overlays = [ inputs.emacs-overlay.overlays.default ];
          };

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
        inputs.catppuccin.homeModules.catppuccin
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
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
            ./nixos/bbstation/boot-loader.nix
            ./nixos/bbstation/hardware-configuration.nix
            ./nixos/io-performance.nix
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
            ./nixos/thinkpad-e14/boot-loader.nix
            ./nixos/thinkpad-e14/hardware-configuration.nix
            ./nixos/io-performance.nix
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
    };
}
