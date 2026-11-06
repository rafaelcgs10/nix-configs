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
      StartLimitIntervalSec = 0; # keep retrying until Music Assistant is up
      After = [ "pipewire.service" "pipewire-pulse.socket" ];
      Wants = [ "pipewire-pulse.socket" ];
    };
    Service = {
      # Wait (briefly) for Music Assistant's player port; started earlier,
      # squeezelite does not find the server and the "vovo" player never
      # appears. Give up after ~60 s and let Restart retry, so a deploy that
      # restarts this unit never blocks on it.
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in $(seq 12); do (exec 3<>/dev/tcp/127.0.0.1/3483) 2>/dev/null && exit 0; sleep 5; done; exit 1'";
      TimeoutStartSec = "90s";
      ExecStart = "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n vovo -s 127.0.0.1 -C 5";
      # Decoding must keep up with playback: ahead of background work, and
      # never swapped out (see nixos/vovo/audio.nix, real-time audio).
      Nice = -5;
      MemorySwapMax = 0;
      Restart = "always";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Fixed audio levels, applied whenever WirePlumber (re)starts:
  # - outputs fixed at 50% (musiCozy 250%, it is much quieter), so the Music Assistant
  #   / Home Assistant player volume is the only volume that matters;
  # - Blue Yeti capture at 72%: at 100% speech clipped at 0 dBFS, which made
  #   the wake word unreliable; 72% peaks around -11 dBFS at normal speaking
  #   distance (measured 2026-11-05). The Yeti is the default source.
  # Then wake the Bluetooth output (a restarted WirePlumber re-creates it
  # suspended; see nixos/vovo/audio.nix).
  systemd.user.services.audio-levels = {
    Unit = {
      Description = "Fixed vovo audio levels (outputs 50%, Yeti 72%)";
      After = [ "wireplumber.service" ];
      PartOf = [ "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.writeShellScript "vovo-audio-levels" ''
        pactl=${pkgs.pulseaudio}/bin/pactl
        ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.72
        # The Bluetooth output reappears some seconds after WirePlumber, if a
        # speaker is connected: keep going for up to a minute.
        for _ in $(${pkgs.coreutils}/bin/seq 12); do
          for sink in $($pactl list short sinks | ${pkgs.coreutils}/bin/cut -f2); do
            case "$sink" in
              *41_42_FE_D5_9B_EF*) $pactl set-sink-volume "$sink" 250% ;; # musiCozy (much quieter); >100% = software boost
              *) $pactl set-sink-volume "$sink" 50% ;;
            esac
          done
          if $pactl list short sinks | ${pkgs.gnugrep}/bin/grep -q bluez_output; then
            ${pkgs.pipewire}/bin/pw-play ${silence} || true
            break
          fi
          ${pkgs.coreutils}/bin/sleep 5
        done
      ''}";
    };
    Install.WantedBy = [ "wireplumber.service" ];
  };

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;
  news.display = "silent";
}
