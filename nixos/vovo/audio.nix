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

      # Blue Yeti: a USB microphone that also exposes a headphone output. Hide
      # that output so music never lands on it, and make the Yeti the
      # preferred microphone.
      "20-blue-yeti" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output.usb-Blue_Microphones_Yeti*"; } ];
            actions.update-props."node.disabled" = true;
          }
          {
            matches = [ { "node.name" = "~alsa_input.usb-Blue_Microphones_Yeti*"; } ];
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
      };
      Policy.AutoEnable = true;
    };
  };
}
