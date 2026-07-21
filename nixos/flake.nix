{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs2511.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    winapps.url = "github:winapps-org/winapps/main";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      mkHost =
        { system ? "x86_64-linux"
        , common ? true
        , modules
        }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = lib.optionals common [ ./configuration.nix ] ++ modules;
        };

      hosts = {
        bbstation = mkHost {
          modules = [
            ./bbstation/boot-loader.nix
            ./bbstation/hardware-configuration.nix
          ];
        };

        bbtablet = mkHost {
          modules = [
            ./bbtablet/boot-loader.nix
            ./bbtablet/hardware-configuration.nix
          ];
        };

        thinkpad-e14 = mkHost {
          modules = [
            ./thinkpad-e14/boot-loader.nix
            ./thinkpad-e14/hardware-configuration.nix
          ];
        };
      };
    in
    {
      nixosConfigurations = hosts // {
        thinkpad = hosts.thinkpad-e14;
      };
    };
}
