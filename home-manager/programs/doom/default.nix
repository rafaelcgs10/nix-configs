{ config, lib, pkgs, pkgsEmacs, ... }:

let
  doomDir = "${config.home.homeDirectory}/nix-configs/home-manager/programs/doom/doom.d";
  doomLocalDir = "${config.home.homeDirectory}/.doom-local";
in
{
  home = {
    sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
    sessionVariables = {
      DOOMDIR = doomDir;
      DOOMLOCALDIR = doomLocalDir;
      OZONE_PLATFORM = "wayland";
    };
  };

  # Run Emacs as a daemon so Doom's startup cost (config + packages) is paid
  # once at login, in the background; frames then open near-instantly via
  # emacsclient. Launch with `emacsclient -c` or the "Emacs (Client)" desktop
  # entry. After `doom sync`, restart with `systemctl --user restart emacs`.
  services.emacs = {
    enable = true;
    package = pkgsEmacs.emacs-pgtk;
    client.enable = true; # adds the "Emacs (Client)" desktop entry
    startWithUserSession = "graphical";
  };

  # The daemon is a systemd user service, which never sources
  # home.sessionVariables (login-shell only) — without these it would look for
  # the Doom config in the default locations and start plain Emacs.
  systemd.user.sessionVariables = {
    DOOMDIR = doomDir;
    DOOMLOCALDIR = doomLocalDir;
  };

  # wordnet provides the `wn' binary + offline WordNet database used by Doom's
  # (lookup +dictionary +offline) backends: wordnut for definitions and
  # synosaurus-wordnet for synonyms.
  home.packages = [ pkgsEmacs.emacs-pgtk pkgsEmacs.hack-font pkgs.wordnet ];
}
