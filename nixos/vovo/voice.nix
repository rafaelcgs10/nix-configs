{ config, lib, pkgs, ... }:

# Local voice pipeline, all on the Pi (it must work with bbstation off):
#
#   Blue Yeti -> wyoming-satellite -> openWakeWord  ("ok nabu" / "hey vovo")
#                       |
#                       +-> Home Assistant Assist pipeline
#                             STT  faster-whisper tiny.en   (tcp 10300)
#                             TTS  Piper lessac-medium      (tcp 10200)
#                       <- spoken reply played through PipeWire
#
# All Wyoming services listen on localhost only; Home Assistant runs here too.
let
  wakeWordDir = "/var/lib/openwakeword/custom";

  # Chimes on wake word / end of command (not shipped in the nixpkgs package).
  satelliteSounds = rec {
    version = "1.4.1"; # keep in step with pkgs.wyoming-satellite
    awake = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/rhasspy/wyoming-satellite/v${version}/sounds/awake.wav";
      hash = "sha256-ayXdKrr3U3hlIiyp/W4U+/cjRYUm+3m74p2CYdEyByQ=";
    };
    done = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/rhasspy/wyoming-satellite/v${version}/sounds/done.wav";
      hash = "sha256-vFyRS/qGCnf6nYisLZZgGt/t5XjPFGY37Ji1aIkRqVE=";
    };
  };

  # Custom wake words trained on bbstation (see README). Copied into the
  # container's model dir; built-in ones (ok_nabu, hey_jarvis, ...) always work.
  customWakeWords = lib.filter lib.pathExists [ ./wakewords/hey_vovo.tflite ];
  wakeWordName = if customWakeWords != [ ] then "hey_vovo" else "ok_nabu";
in
{
  # --- speech to text -----------------------------------------------------------
  services.wyoming.faster-whisper.servers.vovo = {
    enable = true;
    uri = "tcp://127.0.0.1:10300";
    language = "en";
    # `auto` would pick Parakeet (sherpa) for English: far more accurate but
    # ~1 GB of RAM, too much next to Home Assistant on a 2 GB Pi.
    sttLibrary = "faster-whisper";
    model = "tiny.en";
    device = "cpu";
    # Quantize on load: without this tiny.en ran at float32 and took ~430 MB
    # (mostly pushed to swap), which starved everything else.
    extraArgs = [ "--compute-type" "int8" ];
  };

  # --- text to speech -------------------------------------------------------------
  services.wyoming.piper.servers.vovo = {
    enable = true;
    uri = "tcp://127.0.0.1:10200";
    voice = "en_US-lessac-medium";
  };

  # --- wake word -------------------------------------------------------------------
  # nixpkgs' wyoming-openwakeword is marked broken on aarch64 (its bundled
  # tflite segfaults), so run the upstream image, the same build the Home
  # Assistant add-on uses on Raspberry Pis.
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.openwakeword = {
      image = "docker.io/rhasspy/wyoming-openwakeword:2.1.0";
      ports = [ "127.0.0.1:10400:10400" ];
      volumes = [ "${wakeWordDir}:/custom:ro" ];
      # 0.7: suggested by the training run (≈0.44 false activations/hour on
      # speech-heavy audio, ~72% recall on unseen synthetic voices).
      cmd = [ "--custom-model-dir" "/custom" "--threshold" "0.7" ];
      extraOptions = [ "--memory=200m" ];
    };
  };
  systemd.tmpfiles.rules = [ "d ${wakeWordDir} 0755 root root -" ]
    # Copied, not symlinked: a link into /nix/store dangles inside the container.
    ++ map (m: "C+ ${wakeWordDir}/${baseNameOf (toString m)} 0644 root root - ${m}") customWakeWords;

  # --- satellite (microphone + speaker) ------------------------------------------
  # Runs as rafael so it reaches his PipeWire session; arecord/aplay go through
  # PipeWire's ALSA plugin, so the default source (the Yeti) and the current
  # output (jack or Bluetooth speaker) are used.
  services.wyoming.satellite = {
    enable = true;
    user = "rafael";
    name = "vovo";
    uri = "tcp://0.0.0.0:10700"; # Home Assistant connects locally; port stays firewalled
    microphone = {
      command = "arecord -D pipewire -r 16000 -c 1 -f S16_LE -t raw";
      autoGain = 5;
      noiseSuppression = 2;
    };
    sound.command = "aplay -D pipewire -r 22050 -c 1 -f S16_LE -t raw";
    sounds = {
      awake = "${satelliteSounds.awake}";
      done = "${satelliteSounds.done}";
    };
    extraArgs = [
      "--wake-uri" "tcp://127.0.0.1:10400"
      "--wake-word-name" wakeWordName
    ];
  };
  # The satellite needs rafael's PipeWire and the wake word service to be up.
  systemd.services.wyoming-satellite = {
    after = [ "user@1000.service" "podman-openwakeword.service" ];
    wants = [ "user@1000.service" "podman-openwakeword.service" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  };
}
