{ config, pkgs, lib, ... }:

# Home profile for vovo (Raspberry Pi 4, 2 GB music box). Used on its own, NOT
# on top of home-manager/home.nix: that one brings Stylix, GTK/Qt, fonts,
# claude-code and dictionaries, none of which belong on a headless 2 GB Pi.
{
  imports = [
    ../programs/zsh/default.nix
    ../programs/nvim/default.nix
  ];

  home.username = "rafael";
  home.homeDirectory = "/home/rafael";
  home.stateVersion = "26.05";

  # The shared zsh module keeps history in a Syncthing'd ~/zsh_history dir,
  # which does not exist here.
  programs.zsh.history.path = lib.mkForce "$HOME/.zsh_history";

  programs.git = {
    enable = true;
    settings.user = {
      name = "rafaelcgs10";
      email = "rafaelcgs10@gmail.com";
    };
  };

  programs.htop.enable = true;
  programs.fzf.enable = true; # nvim's fzf-vim

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    ncdu        # what is filling the 32 GB card?
    alsa-utils  # arecord/aplay/alsamixer: test the Yeti and the jack
    pulsemixer  # volume / default device over SSH
  ];

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;
  news.display = "silent";
}
