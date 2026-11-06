{ config, lib, pkgs, ... }:

# Audio: PipeWire as rafael's *user* session (users.users.rafael.linger keeps it
# running without a login). nixpkgs' wyoming-satellite module expects exactly
# this (XDG_RUNTIME_DIR=/run/user/$UID), and user-session PipeWire is the
# well-trodden path for Bluetooth. Squeezelite runs as a Home Manager user
# service next to it.
{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true; # squeezelite-pulse and pactl talk to pipewire-pulse
    wireplumber.enable = true;

    wireplumber.extraConfig = {
      # Headless: by default WirePlumber only runs the Bluetooth monitor for the
      # user on the active logind seat, which a lingering user never is.
      "10-headless-bluetooth" = {
        "wireplumber.profiles".main."monitor.bluez.seat-monitoring" = "disabled";
        # Keep a Bluetooth speaker in high-quality A2DP; never flip it to the
        # headset profile just because something opens a microphone (the
        # microphone is the Yeti).
        "wireplumber.settings"."bluetooth.autoswitch-to-headset-profile" = false;
      };

      # Output preference: MEGABOOM 3 > musiCozy > any other Bluetooth speaker
      # > 3.5 mm jack; HDMI never. WirePlumber picks the available sink with the
      # highest priority as the default, so when a speaker is switched off or
      # goes out of range its sink disappears and playback falls back to the
      # next one, and when it reconnects it takes over again (playing streams
      # follow the default).
      # Do not pin a default with `wpctl set-default`: a user-chosen default
      # overrides these priorities.
      "30-output-priority" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output\\.platform-.*hdmi.*"; } ];
            actions.update-props."node.disabled" = true;
          }
          {
            # bcm2835 headphone jack ("Built-in Audio Stereo")
            matches = [ { "node.name" = "~alsa_output\\.platform-.*mailbox.*"; } ];
            actions.update-props = {
              "priority.session" = 1500;
              "priority.driver" = 1500;
            };
          }
        ];
        # Every matching rule is applied in order, so the per-speaker rules
        # below override the generic priority.
        "monitor.bluez.rules" = [
          {
            # Any other Bluetooth speaker: below the known ones, above the jack.
            matches = [ { "node.name" = "~bluez_output\\..*"; } ];
            actions.update-props = {
              "priority.session" = 2000;
              "priority.driver" = 2000;
              # Never suspend the A2DP link while connected. Waking it takes
              # 1-2 s, which swallowed the 0.4 s wake/done chimes entirely
              # and the first syllable of spoken replies. Trade-off: the
              # speaker's own idle auto-off may not kick in while connected.
              "session.suspend-timeout-seconds" = 0;
            };
          }
          {
            # MEGABOOM 3: first choice.
            matches = [ { "node.name" = "~bluez_output\\.10_94_97_03_B3_BE\\..*"; } ];
            actions.update-props = {
              "priority.session" = 3000;
              "priority.driver" = 3000;
            };
          }
          {
            # musiCozy: second choice.
            matches = [ { "node.name" = "~bluez_output\\.41_42_FE_D5_9B_EF\\..*"; } ];
            actions.update-props = {
              "priority.session" = 2500;
              "priority.driver" = 2500;
            };
          }
        ];
      };

      # Blue Yeti: a USB microphone that also exposes a headphone output. Hide
      # that output so music never lands on it, and make the Yeti the
      # preferred microphone. Newer (Logitech-made) units report as
      # "usb-Generic_Blue_Microphones_LT_...". `~` makes these regexes.
      "20-blue-yeti" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output\\.usb-.*Blue_Microphones.*"; } ];
            actions.update-props."node.disabled" = true;
          }
          {
            matches = [ { "node.name" = "~alsa_input\\.usb-.*Blue_Microphones.*"; } ];
            actions.update-props = {
              "priority.session" = 2100;
              "priority.driver" = 2100;
            };
          }
        ];
      };
    };
  };

  # PipeWire is normally socket-activated on first use. Start it (and with it
  # WirePlumber) at boot instead, so a paired Bluetooth speaker reconnects and
  # devices are ready before anything asks for them.
  systemd.user.services.pipewire.wantedBy = [ "default.target" ];

  # Real-time audio. PipeWire raises its audio threads to SCHED_FIFO itself
  # (rt.prio 88, nice -11) when its resource limits allow it, and otherwise
  # asks rtkit, which only grants that to an *active* login session. A
  # lingering, headless session never is one, so PipeWire, WirePlumber,
  # pipewire-pulse and squeezelite all ran at normal priority (measured
  # 2026-11-06: RLIMIT_RTPRIO 0, every thread SCHED_OTHER), and any CPU burst
  # (wake word, speech-to-text, Home Assistant, a YouTube download) could make
  # music and vovo's voice stutter. The kernel allows it (no RT_GROUP_SCHED;
  # `chrt -f -p 88` on a data-loop thread worked). Grant the limits to the
  # user manager, which every user service inherits; the satellite (microphone
  # and speaker) gets them in voice.nix. Needs `systemctl restart user@1000`
  # (or a reboot) to apply to the running session.
  systemd.services."user@".serviceConfig = {
    LimitRTPRIO = 95;
    LimitNICE = -19;
  };
  # Never swap the audio daemons out: a page fault (zram or the SD-card swap
  # file) in the middle of playback is an audible gap.
  systemd.user.services.pipewire.serviceConfig.MemorySwapMax = 0;
  systemd.user.services.pipewire-pulse.serviceConfig.MemorySwapMax = 0;
  systemd.user.services.wireplumber.serviceConfig.MemorySwapMax = 0;

  # Reconnect the paired speakers whenever they are on but not connected:
  # after a reboot, a PipeWire restart or when they come back into range. A
  # speaker only reconnects by itself when it is switched on, not when the Pi
  # drops the link. Without it, playback stays on the 3.5 mm jack (see
  # priorities).
  systemd.services.bluetooth-speaker-reconnect = {
    description = "Reconnect the paired Bluetooth speakers";
    after = [ "bluetooth.service" ];
    path = [ pkgs.bluez pkgs.gnugrep pkgs.util-linux ];
    script =
      let
        # 1 s of silence: wakes the A2DP link right after (re)connecting, so
        # the first real sound (a chime, a reply) is not swallowed. With
        # suspend disabled (above) it then stays awake while connected.
        silence = pkgs.runCommand "silence-1s.wav" { nativeBuildInputs = [ pkgs.sox ]; } ''
          sox -n -r 48000 -c 2 -b 16 $out trim 0 1
        '';
      in
      ''
        # Priority order: MEGABOOM 3, musiCozy.
        speakers="10:94:97:03:B3:BE 41:42:FE:D5:9B:EF"
        connected() { bluetoothctl info "$1" | grep -q "Connected: yes"; }

        # Only page when no speaker is connected. Paging an absent speaker
        # (bluetoothctl connect) keeps the radio busy for the 5 s page
        # timeout and starves the A2DP stream of the speaker that is
        # playing: with this timer at 30 s, music on the MEGABOOM stuttered
        # every 30-60 s while the musiCozy was off (measured 2026-11-06:
        # 12 page timeouts in 10 min; stopping the timer fixed it). A speaker
        # switched on later reconnects by itself and takes over by priority.
        any=""
        for mac in $speakers; do
          if connected "$mac"; then any=1; else rm -f "/run/bluetooth-speaker-woken-''${mac//:/_}"; fi
        done
        if [ -z "$any" ]; then
          for mac in $speakers; do
            bluetoothctl --timeout 10 connect "$mac" >/dev/null 2>&1 || true
            sleep 3
            connected "$mac" && break
          done
        fi

        for mac in $speakers; do
          connected "$mac" || continue
          woken=/run/bluetooth-speaker-woken-''${mac//:/_}
          # Fixed output level per speaker (musiCozy is much quieter: 250%, a software boost).
          case "$mac" in
            41:42:FE:D5:9B:EF) vol=250% ;; # >100% = software boost (chosen by ear)
            *) vol=50% ;;
          esac
          # Connected (by us or by the speaker itself): once per connection,
          # put its output at its fixed level (the player volume in Music Assistant is the
          # one that is controlled; this also sets the speaker's own volume via
          # Bluetooth absolute volume) and wake the link.
          if [ ! -e "$woken" ]; then
            sleep 2
            runuser -u rafael -- env XDG_RUNTIME_DIR=/run/user/1000 \
              ${pkgs.pulseaudio}/bin/pactl set-sink-volume bluez_output.''${mac//:/_}.1 "$vol" || true
            runuser -u rafael -- env XDG_RUNTIME_DIR=/run/user/1000 \
              ${pkgs.pipewire}/bin/pw-play --target bluez_output.''${mac//:/_}.1 ${silence} && touch "$woken"
          fi
        done
      '';
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.bluetooth-speaker-reconnect = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "30s";
    };
  };

  # Onboard Bluetooth (BCM43455 on the UART). Pairing is a one-time
  # `bluetoothctl` step (see README); the trust persists in /var/lib/bluetooth.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Reconnect to a known speaker as soon as it is switched on.
        FastConnectable = true;
        JustWorksRepairing = "always";
        # Without a desktop there is usually no pairing agent running, and
        # then BlueZ only does throw-away (non-bonded) pairings: the speaker
        # pairs, then refuses the audio connection (avdtp "Permission denied").
        AlwaysPairable = true;
      };
      Policy.AutoEnable = true;
    };
  };
}
