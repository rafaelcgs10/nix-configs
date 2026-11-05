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

      # Output preference: Bluetooth speaker > 3.5 mm jack; HDMI never.
      # WirePlumber picks the available sink with the highest priority as the
      # default, so when the MEGABOOM is switched off or goes out of range its
      # sink disappears and playback falls back to the jack, and when it
      # reconnects it takes over again (playing streams follow the default).
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
        "monitor.bluez.rules" = [
          {
            matches = [ { "node.name" = "~bluez_output\\..*"; } ];
            actions.update-props = {
              "priority.session" = 3000;
              "priority.driver" = 3000;
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

  # Reconnect the paired speaker whenever it is on but not connected: after
  # a reboot, a PipeWire restart or when it comes back into range. The speaker
  # only reconnects by itself when it is switched on, not when the Pi drops
  # the link. Without it, playback stays on the 3.5 mm jack (see priorities).
  systemd.services.bluetooth-speaker-reconnect = {
    description = "Reconnect the MEGABOOM 3 Bluetooth speaker";
    after = [ "bluetooth.service" ];
    path = [ pkgs.bluez pkgs.gnugrep ];
    script = ''
      mac=10:94:97:03:B3:BE  # MEGABOOM 3
      bluetoothctl info "$mac" | grep -q "Connected: yes" && exit 0
      bluetoothctl --timeout 10 connect "$mac" >/dev/null 2>&1 || true
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
