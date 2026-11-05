{ config, pkgs, lib, ... }:

let
  silence = pkgs.runCommand "silence-1s.wav" { nativeBuildInputs = [ pkgs.sox ]; } ''
    sox -n -r 48000 -c 2 -b 16 $out trim 0 1
  '';
in

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

  # The player Music Assistant streams to (slimproto on localhost:3483). Runs
  # in rafael's session so it plays through PipeWire: the 3.5 mm jack, or a
  # connected Bluetooth speaker. -C 5 releases the output after 5 s idle so
  # PipeWire can re-route to a speaker that connects later.
  systemd.user.services.squeezelite = {
    Unit = {
      Description = "Squeezelite player for Music Assistant";
      After = [ "pipewire.service" "pipewire-pulse.socket" ];
      Wants = [ "pipewire-pulse.socket" ];
    };
    Service = {
      ExecStart = "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n vovo -s 127.0.0.1 -C 5";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Blue Yeti capture level. At 100% (WirePlumber's default) speech clipped
  # at 0 dBFS, which made the wake word unreliable; 72% peaks around -11 dBFS
  # at normal speaking distance (measured 2026-11-05). The Yeti is the default
  # source (see nixos/vovo/audio.nix), so it can be addressed as such.
  systemd.user.services.yeti-mic-level = {
    Unit = {
      Description = "Set the Blue Yeti capture level, wake the Bluetooth output";
      After = [ "wireplumber.service" ];
      PartOf = [ "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = [
        "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.72"
        # A restarted WirePlumber re-creates the Bluetooth output suspended;
        # wake it so the next chime is not swallowed (see nixos/vovo/audio.nix).
        "-${pkgs.pipewire}/bin/pw-play ${silence}"
      ];
    };
    Install.WantedBy = [ "wireplumber.service" ];
  };

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;
  news.display = "silent";
}
