{ pkgs, ...}:

let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz"; });})];};
  solarized-everything-css = pkgs.callPackage ../solarized-everything-css { };
  css = "${solarized-everything-css}/share/css";
in
{
  home.packages = [
    pkgs.spotify
    pkgs.whatsapp-for-linux
    pkgs.insomnia
    pkgs.tdesktop
    pkgs.obs-studio
    pkgs.lutris
    pkgs.tlaplusToolbox
    unstable.discord
    pkgs.bitwarden

    pkgs.google-cloud-sdk
    pkgs.vivaldi
  ];

  programs.qutebrowser = {
    enable = true;
    settings = {
      auto_save.session = true;
      spellcheck.languages = [ "en-US" "pt-BR" ];
      colors.webpage.preferred_color_scheme = "dark";
    };

    keyBindings = {
      normal = {
        "<Ctrl-r>" = "config-cycle content.user_stylesheets '${css}/darculized-all-sites.css' ''";
      };
    };
  };
}
