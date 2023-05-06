{pkgs, config, ...}: let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
  }).defaultNix;

  mypkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/60d89a0fc218cdb3428be53c2d8ba3c63dc6881c.tar.gz";
  }) {};

in {
  imports = [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    systemdIntegration = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  home.packages = [ mypkgs.xdg-desktop-portal-wlr  ];

  programs.waybar =
    {
      enable = true;
      package = mypkgs.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or  [ ]) ++ [ "-Dexperimental=true" ];
        patchPhase = ''
        substituteInPlace src/modules/wlr/workspace_manager.cpp --replace "zext_workspace_handle_v1_activate(workspace_handle_);" "const std::string command = \"${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch workspace \" + name_; system(command.c_str());"
      '';
      });
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 20;
          output = [ "eDP-1" "HDMI-A-1" ];
          modules-left = [ "wlr/workspaces" "hyprland/submap" ];
          modules-center = [ "hyprland/window"  ];
          modules-right = [ "tray" "temperature" "cpu" "memory" "clock" ];
          "wlr/workspaces" = {
            format = "{icon}";
            active-only = false;
            on-click = "activate";
          };
        };
      };
      style = builtins.readFile ./style.css;
    };

  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      mobile = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable"; # null, "enable", "disable"
            mode = "1920x1080";
            position = "1920,0"; # null, or example
            scale = null; # null or int
            transform = null;
          }
        ];
      };
      docked = {
        outputs = [
          {
            criteria = "HDMI-A-1";
            status = "enable"; # null, "enable", "disable"
            mode = "1920x1080";
            position = "0,0"; # null, or example
            scale = null; # null or int
            transform = null;
          }
          {
            criteria = "eDP-1";
            status = "enable"; # null, "enable", "disable"
            mode = "1920x1080";
            position = "1920,0"; # null, or example
            scale = null; # null or int
            transform = null;
          }
        ];
      };
    };

  };
}
